extends CanvasLayer

var ocultado = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ocultar") and ocultado == false:
		$NodeUI/ColorRect.anchor_left = 1
		$NodeUI/ColorRect/Label.visible = false
		ocultado = true
	elif Input.is_action_just_pressed("ocultar") and ocultado == true:
		$NodeUI/ColorRect.anchor_left = 0.687
		$NodeUI/ColorRect/Label.visible = true
		ocultado = false
