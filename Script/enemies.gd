extends Node

@export var player:Player
@export var quest_manager:QuestManager
@export var number_enemies_to_spawn:int = 10
var current_enemies_spawned:int = 0
var is_atived:bool = false
var ended:bool = false

@onready var progress_bar:ProgressBar = $"../UIManager/MissionScreen/ProgressBar"

func _ready() -> void:
	progress_bar.value = 0

func active():
	progress_bar.value = 0
	is_atived = true

func _process(delta: float) -> void:
	if not is_atived: return
	if ended:
		progress_bar.value = 0
		return
	
	
	
	if progress_bar.value < 100:
		var value:int = randi_range(1,4)
		progress_bar.value+=delta*(100/value)
	elif progress_bar.value >= 100:
		progress_bar.value = 0
		spawn_enemy()

func spawn_enemy() -> void:
	#print(current_enemies_spawned, " | ", number_enemies_to_spawn," | ", current_enemies_spawned > number_enemies_to_spawn)
	if current_enemies_spawned >= number_enemies_to_spawn: 
		ended = true
		return
	
	var enemy := preload("res://Cenas/enemy.tscn").instantiate()
	var offset := [60, -60]
	enemy.position = player.position + Vector2(
		offset[randi_range(0, 1)],
		offset[randi_range(0, 1)]
	)
	current_enemies_spawned+=1
	add_child(enemy)
	#enemy.died.connect(quest_manager.inimigo_morto)
	enemy.count_delivered.connect(quest_manager.recive_count)
