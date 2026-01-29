class_name WorldManager extends Node

var duracao_dia: float = 60.0 # segundos

var tempo: float = 0.0

# =========================
# ESTADOS
# =========================
enum WorldState { IDLE, READING, COMBAT }
var state: WorldState = WorldState.IDLE
const COMBAT_TIME = 0.76
var limite_inimigos: PackedInt32Array = [10, 20, 50, 15, 1]
var inimigos_derrotados: int = 0
@export var luz: PointLight2D
@export var day_cycle: CanvasModulate
@export var player: Node2D
@export var enemies_container: Node
@export var hud_tempo: Label
@export var countdown: Timer
@export var SoundManager: Node
@export var npc_scene: PackedScene
@export var npc_parent: Node2D
const music: Array[AudioStream] = [
	preload("res://Assets/Sound/theme melodia.wav"),
	preload("res://Assets/Sound/ominousdark-medievalfantasy-song-309510.mp3"),
	preload("res://Assets/Sound/Ville Theme.wav"),
	preload("res://Assets/Sound/Floresta tema.wav")
]
var current_music_node: AudioStreamPlayer2D


# =========================
# READY
# =========================
func _ready() -> void:
	luz.visible = false
	hud_tempo.visible = false
	countdown.stop()
	
	play_world_music(0, player.position,"Normal")
	start_idle()  # Começa no estado IDLE

# =========================
# DEBUG
# =========================
func print_state(sufix: String = "") -> void:
	var state_name = WorldState.keys()[state]
	print("World ESTADO: %s%s" % [state_name, " - " + sufix if not sufix.is_empty() else ""])


# =========================
# ESTADOS
# =========================
func start_idle() -> void:
	state = WorldState.IDLE
	print_state()
	hud_tempo.visible = false
	countdown.stop()
	spawnar_npc()

func start_reading() -> void:
	if state != WorldState.IDLE:
		return
	state = WorldState.READING
	print_state()
	
	hud_tempo.visible = false

func start_combat() -> void:
	day_cycle.color = calcular_cor(0.76)
	if state != WorldState.READING:
		return
	play_world_music(1, player.position, "Batalha")
	
	state = WorldState.COMBAT
	print_state("Combate iniciado")
	inimigos_derrotados = 0
	countdown.start(randi_range(2, 4))
	GameData.iniciou_combat = true


# =========================
# NPC
# =========================
func spawnar_npc() -> void:
	if is_instance_valid(npc_parent):
		npc_parent.queue_free()
	npc_parent.name = "NPC"
	npc_parent = npc_scene.instantiate()
	call_deferred("add_child", npc_parent)
	
	const spawn_pos_list: Array[Vector2] = [
		Vector2(244, 105),	
		Vector2(620, 188),
		Vector2(244, 105),
		Vector2(620, 188),
		Vector2(776, 414)
	]
	npc_parent.position = spawn_pos_list[GameData.missao_atual]
	npc_parent.visible = true
	
	start_reading()

# =========================
# HUD
# =========================
func _physics_process(delta: float) -> void:
	if state != WorldState.COMBAT:
		tempo += delta
		var t := fmod(tempo / duracao_dia, 1.0)
		day_cycle.color = calcular_cor(t)
		#print(t)
		luz.visible = t > 0.6

	else:
		# Noite fixa durante o combate
		luz.visible = true
		day_cycle.color = calcular_cor(COMBAT_TIME)

	match state:
		WorldState.IDLE, WorldState.READING:
			hud_tempo.visible = false
		
		WorldState.COMBAT:
			hud_tempo.visible = true
			hud_tempo.text = str(floori(countdown.time_left))

func calcular_cor(t: float) -> Color:
	if t < 0.25:
		# Dia → Tarde
		return Color(1,1,1).lerp(Color(1,0.85,0.7), t / 0.25)
	elif t < 0.5:
		# Tarde → Noite
		return Color(1,0.85,0.7).lerp(Color(0.2,0.2,0.35), (t - 0.25) / 0.25)
	elif t < 0.75:
		# Noite → Madrugada
		return Color(0.2,0.2,0.35).lerp(Color(0.1,0.1,0.2), (t - 0.5) / 0.25)
	else:
		# Madrugada → Dia
		return Color(0.1,0.1,0.2).lerp(Color(1,1,1), (t - 0.75) / 0.25)


# =========================
# LEITURA / MISSÃO
# =========================
func leitura_concluida() -> void:
	if state != WorldState.READING:
		return
	GameData.has_died = false
	GameData.pegou_missao = true
	start_combat()

func cancelar_missao() -> void:
	if state != WorldState.READING:
		return
	
	print_state("Missão cancelada")
	
	countdown.stop()
	GameData.pegou_missao = false
	GameData.iniciou_combat = false
	
	start_idle()


# =========================
# INIMIGOS
# =========================
func _on_countdown_timeout() -> void:
	if state != WorldState.COMBAT:
		return
	
	countdown.start(randi_range(0, 5))
	
	var enemy := preload("res://Cenas/enemy.tscn").instantiate()
	var offset := [60, -60]
	
	enemy.position = player.position + Vector2(
		offset[randi_range(0, 1)],
		offset[randi_range(0, 1)]
	)
	
	enemies_container.add_child(enemy)
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	inimigos_derrotados += 1
	if inimigos_derrotados >= limite_inimigos[GameData.missao_atual]:
		finalizar_missao()


# =========================
# FINAL
# =========================
func finalizar_missao() -> void:
	print("Missão concluída")
	
	luz.visible = false
	play_world_music(0, player.position, "Normal")
	
	# Destruir todos os inimigos
	for enemy in enemies_container.get_children():
		enemy.queue_free()
	
	start_idle()
	GameData.has_died = false
	#GameData.iniciou_combat = false
	GameData.pegou_missao = false
	GameData.missao_atual = min(GameData.missao_atual + 1, GameData.limite_de_inimigos.size() - 1)
	print("GameData.missao_atual: %s" % GameData.missao_atual)


# =========================
# SOM
# =========================
func play_world_music(music_index: int, pos: Vector2, song_name: String):
	if current_music_node:
		# Não tocar a mesma música se já tiver tocando
		if current_music_node.name == song_name: 
			return
		# Destruir a música que está tocando pra tocar a nova musica
		current_music_node.queue_free()
	
	current_music_node = SoundEffect.play_music(music[music_index], SoundManager, pos, song_name)


func _on_label_area_body_entered(body: Node2D) -> void:
	if not GameData.pegou_missao and body.is_in_group("Player"):
		play_world_music(2, player.position, "Vila")
		$CanvasLayer/Label.text = "Alvelas Village"
		$CanvasLayer/Label/Timer.start()
		await $CanvasLayer/Label/Timer.timeout
		$CanvasLayer/Label.text = ""


func _on_label_area_body_exited(body: Node2D) -> void:
	if not GameData.pegou_missao and body.is_in_group("Player"):
		play_world_music(3, player.position, "Forest")
		$CanvasLayer/Label.text = "Forest"
		$CanvasLayer/Label/Timer.start()
		await $CanvasLayer/Label/Timer.timeout
		$CanvasLayer/Label.text = ""
