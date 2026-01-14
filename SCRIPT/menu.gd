extends Control

const world_scene = preload("res://Cenas/world.tscn")

@onready var start_text: Label = $StartText
@onready var start_text_animp: AnimationPlayer = $StartText/AnimationPlayer
@onready var game_name_animp: AnimationPlayer = $GameName/AnimationPlayer
@onready var start_game_timer: Timer = $StartText/StartGameTimer


func _ready() -> void:
	game_name_animp.play("wave")
	start_text_animp.play("blink")

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	
	if start_text.visible and Input.is_action_just_pressed("enter"):
		start_text_animp.play("enter")
		start_game_timer.start()


func _on_start_game_timer_timeout() -> void:
	get_tree().change_scene_to_packed(world_scene)
