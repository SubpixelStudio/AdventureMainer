extends CanvasLayer


@onready var mission_panel: ColorRect = %MissionPanel
@onready var mission_text: Label = mission_panel.get_node("MissionText")

var ocultado: bool = true

func _ready() -> void:
	ocultar(ocultado)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ocultar"):
		ocultar(!ocultado)


func ocultar(_sim: bool) -> void:
	
	mission_text.visible = not mission_text.visible
	mission_panel.anchor_left = 0.687 if mission_text.visible else 1.0
	ocultado = mission_text.visible
	
	#if sim:
	#	mission_panel.anchor_left = 1
	#	mission_text.visible = false
	#	ocultado = true
	#else:
	#	mission_panel.anchor_left = 0.687
	#	mission_text.visible = true
	#	ocultado = false
