extends Node

@export var countdown:Timer
@export var player:Player
@export var quest_manager:QuestManager
func _ready() -> void:
	countdown.timeout.connect(spawn_enemy)

func spawn_enemy() -> void:
	countdown.start(randi_range(0, 5))
	var enemy := preload("res://Cenas/enemy.tscn").instantiate()
	var offset := [60, -60]
	enemy.position = player.position + Vector2(
		offset[randi_range(0, 1)],
		offset[randi_range(0, 1)]
	)
	add_child(enemy)
	enemy.died.connect(quest_manager.inimigo_morto)
