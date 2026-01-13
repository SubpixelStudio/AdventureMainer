class_name WorldManager
extends Node

# ---------------- ESTADOS ----------------
var state: String = "IDLE"
var missao_atual := 0

var limite_inimigos := [10, 20, 50, 15, 1]
var inimigos_derrotados = GameData.inimigos_derrotados

var iniciou_combat = GameData.iniciou_combat

@export var player: Node2D
@export var enemies_container: Node
@export var hud_tempo: Label
@export var countdown: Timer

@export var npc_scene: PackedScene
@export var npc_parent: Node2D
  
# ---------------- READY ----------------
func _ready():
	hud_tempo.visible = false
	countdown.stop()
	start_idle()  # Começa no estado IDLE

# ---------------- ESTADOS ----------------
func start_idle():
	state = "IDLE"
	hud_tempo.visible = false
	countdown.stop()
	spawnar_npc()
	print("Estado: IDLE")

func start_reading():
	if state != "IDLE":
		return
	state = "READING"
	hud_tempo.visible = false
	print("Estado: READING")

func start_combat():
	if state != "READING":
		return
	state = "COMBAT"
	inimigos_derrotados = 0
	countdown.start(randi_range(2,4))
	print("Estado: COMBAT - Combate iniciado") 
	GameData.iniciou_combat = true

# ---------------- NPC ----------------
func spawnar_npc():
	if is_instance_valid(npc_parent):
		npc_parent.call_deferred("queue_free")

	npc_parent = npc_scene.instantiate()
	call_deferred("add_child", npc_parent)


	# Define referência para este WorldManager
	if npc_parent.has_node("."):
		var npc_script = npc_parent.get_child(0)
		npc_script.world = self

	var posicoes = [
		Vector2(244,105),
		Vector2(620,188),
		Vector2(244,105),
		Vector2(620,188),
		Vector2(776,414)
	]
	npc_parent.position = posicoes[GameData.missao_atual]
	npc_parent.visible = true

	# Começa a leitura quando o NPC aparece
	start_reading()

# ---------------- HUD ----------------
func _physics_process(_delta):
	match state:
		"IDLE", "READING":
			hud_tempo.visible = false
		"COMBAT":
			hud_tempo.visible = true
			hud_tempo.text = str(floori(countdown.time_left))

# ---------------- LEITURA ----------------
func leitura_concluida():
	start_combat()
	GameData.pegou_missao = true

# ---------------- INIMIGOS ----------------
func _on_countdown_timeout():
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

func _on_enemy_died():
	inimigos_derrotados += 1
	if inimigos_derrotados >= limite_inimigos[GameData.missao_atual]:
		finalizar_missao()

# ---------------- FINAL ----------------
func finalizar_missao():
	print("Missão concluída")
	start_idle()
	Global.indice += 1
	print("Indice global agora: %s" % Global.indice)
	GameData.iniciou_combat = false
	GameData.pegou_missao = false
	GameData.missao_atual = clamp(GameData.missao_atual + 1, 0, GameData.limite_de_inimigos.size() - 1)
