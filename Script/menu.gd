extends Control

const world_scene = preload("res://Cenas/world.tscn")
@export var btn:Array[Button]
var action := {}
@onready var anim_player:AnimationPlayer =  $AnimationPlayer


func _ready() -> void:
	action = {
		0: changed,
		3: quit,
	}
	for i in range(btn.size()):
		btn[i].pressed.connect(connect_button.bind(i))

func connect_button(id:int) -> void:
	if action.has(id):
		action[id].call()

func changed():
	get_tree().change_scene_to_packed(world_scene)

func quit():
	get_tree().quit()

func camera_animation(animation_string:String):
	anim_player.play(animation_string)
