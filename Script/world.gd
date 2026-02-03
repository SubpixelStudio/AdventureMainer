class_name WorldManager extends Node
@export var hud_tempo: Label
func _ready() -> void:
	$TouchButton.visible = OS.get_name() == "Android"
	hud_tempo.visible = false
