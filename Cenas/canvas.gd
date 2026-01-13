extends CanvasLayer

@onready var mission_panel: ColorRect = %MissionPanel
@onready var mission_text: Label = mission_panel.get_node("MissionText")

var ocultado: bool = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ocultar") and ocultado == false:
		mission_panel.anchor_left = 1
		mission_text.visible = false
		ocultado = true
	elif Input.is_action_just_pressed("ocultar") and ocultado == true:
		mission_panel.anchor_left = 0.687
		mission_text.visible = true
		ocultado = false
