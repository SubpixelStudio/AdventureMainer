extends Control

@export var btn : Array[Button]
var action = {}

func _ready() -> void:
	hide() 
	action = {
		0: resume,
		1: settings,
		2: menu,
		3: quit
	}
	for i in range(btn.size()):
		btn[i].pressed.connect(connect_button.bind(i))

func connect_button(id:int) -> void:
	if action.has(id):
		action[id].call()

func settings():
	get_tree().change_scene_to_file("res://Cenas/settings.tscn")

func resume():
	get_tree().paused = false
	hide()

func menu():
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")

func quit():
	get_tree().quit()
