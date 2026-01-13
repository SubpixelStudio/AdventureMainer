class_name WorldManager extends Node

# ---------------- ESTADOS ----------------
var state: String = "IDLE"

var limite_inimigos: PackedInt32Array = [10, 20, 50, 15, 1]
var inimigos_derrotados: int = GameData.inimigos_derrotados

#var iniciou_combat = GameData.iniciou_combat		# Não usado

@export var player: Node2D
@export var enemies_container: Node
@export var hud_tempo: Label
@export var countdown: Timer

@export var npc_scene: PackedScene
@export var npc_parent: Node2D
  
# ---------------- READY ----------------
func _ready() -> void:
	hud_tempo.visible = false
	countdown.stop()
	start_idle()  # Começa no estado IDLE

# ---------------- ESTADOS ----------------
func print_state(sufix: String = "") -> void:
	print("World ESTADO: %s%s" % [state, " - " + sufix if not sufix.is_empty() else ""])

func start_idle() -> void:
	state = "IDLE"
	print_state()
	hud_tempo.visible = false
	countdown.stop()
	spawnar_npc()

func start_reading() -> void:
	if state != "IDLE":
		return
	state = "READING"
	print_state()
	hud_tempo.visible = false

func start_combat() -> void:
	if state != "READING":
		return
	state = "COMBAT"
	print_state("Combate iniciado")
	inimigos_derrotados = 0
	countdown.start(randi_range(2,4))
	GameData.iniciou_combat = true

# ---------------- NPC ----------------
func spawnar_npc() -> void:
	if is_instance_valid(npc_parent):
		npc_parent.call_deferred("queue_free")
	
	npc_parent = npc_scene.instantiate()
	call_deferred("add_child", npc_parent)
	
	# Define referência para este WorldManager
	if npc_parent.has_node("."):				# b: Pq ele verifica se tem ele mesmo?
		var npc_script = npc_parent.get_child(0)
		npc_script.world = self
	
	const posicoes: Array[Vector2] = [
		Vector2(244, 105),
		Vector2(620, 188),
		Vector2(244, 105),
		Vector2(620, 188),
		Vector2(776, 414)
	]
	npc_parent.position = posicoes[GameData.missao_atual]
	npc_parent.visible = true
	
	# Começa a leitura quando o NPC aparece
	start_reading()

# ---------------- HUD ----------------
func _physics_process(_delta: float) -> void:
	match state:
		"IDLE", "READING":
			hud_tempo.visible = false
		"COMBAT":
			hud_tempo.visible = true
			hud_tempo.text = str(floori(countdown.time_left))

# ---------------- LEITURA ----------------
func leitura_concluida() -> void:
	start_combat()
	GameData.pegou_missao = true

# ---------------- INIMIGOS ----------------
func _on_countdown_timeout() -> void:
	countdown.start(randi_range(0,5))
	if state != "COMBAT":
		return

	var enemy = preload("res://Cenas/enemy.tscn").instantiate()
	enemy.position = player.position + Vector2(
		randf_range(-60, 60),
		randf_range(-60, 60)
	)
	enemies_container.add_child(enemy)
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	inimigos_derrotados += 1
	if inimigos_derrotados >= limite_inimigos[GameData.missao_atual]:
		finalizar_missao()

# ---------------- FINAL ----------------
func finalizar_missao() -> void:
	print("Missão concluída")
	start_idle()
	GameData.iniciou_combat = false
	GameData.pegou_missao = false
	GameData.missao_atual = clamp(GameData.missao_atual + 1, 0, GameData.limite_de_inimigos.size() - 1)
	print("GameData.missao_atual: %s" % GameData.missao_atual)
