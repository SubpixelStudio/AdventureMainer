class_name WorldManager
extends Node

# =========================
# ESTADOS
# =========================
enum WorldState { IDLE, READING, COMBAT }
var state: WorldState = WorldState.IDLE

var limite_inimigos: PackedInt32Array = [10, 20, 50, 15, 1]
var inimigos_derrotados: int = 0

@export var player: Node2D
@export var enemies_container: Node
@export var hud_tempo: Label
@export var countdown: Timer

@export var npc_scene: PackedScene
@export var npc_parent: Node2D


# =========================
# READY
# =========================
func _ready() -> void:
	hud_tempo.visible = false
	countdown.stop()
	start_idle()


# =========================
# DEBUG
# =========================
func print_state(sufix: String = "") -> void:
	var nome_estado = WorldState.keys()[state]
	print("World ESTADO: %s%s" % [nome_estado, " - " + sufix if not sufix.is_empty() else ""])


# =========================
# ESTADOS
# =========================
func start_idle() -> void:
	state = WorldState.IDLE
	print_state()

	hud_tempo.visible = false
	countdown.stop()

	GameData.iniciou_combat = false
	GameData.pegou_missao = false

	spawnar_npc()


func start_reading() -> void:
	if state != WorldState.IDLE:
		return

	state = WorldState.READING
	print_state()

	hud_tempo.visible = false


func start_combat() -> void:
	if state != WorldState.READING:
		return

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
	npc_parent = npc_scene.instantiate()
	add_child(npc_parent)

	const posicoes := [
		Vector2(244, 105),
		Vector2(620, 188),
		Vector2(244, 105),
		Vector2(620, 188),
		Vector2(776, 414)
	]

	npc_parent.position = posicoes[GameData.missao_atual]
	npc_parent.visible = true

	start_reading()


# =========================
# HUD
# =========================
func _physics_process(_delta: float) -> void:
	match state:
		WorldState.IDLE, WorldState.READING:
			hud_tempo.visible = false

		WorldState.COMBAT:
			hud_tempo.visible = true
			hud_tempo.text = str(floori(countdown.time_left))


# =========================
# LEITURA / MISSÃO
# =========================
func leitura_concluida() -> void:
	if state != WorldState.READING:
		return
	GameData.has_dead = false
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
	GameData.has_dead = false
	start_idle()

	GameData.missao_atual = clamp(
		GameData.missao_atual + 1,
		0,
		limite_inimigos.size() - 1
	)

	print("GameData.missao_atual: %s" % GameData.missao_atual)
