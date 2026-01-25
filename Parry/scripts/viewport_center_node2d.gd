@tool
extends SubViewport

@export var centerChildren: bool = false:
	set = _set_centered

@onready var _cachedChildren = get_children()


func _ready():
	if Engine.is_editor_hint():
		return
	
	_set_centered(true)

func _set_centered(newValue: bool):
	centerChildren = newValue
	var centerPos = size * .5
	for child in _cachedChildren:
		child.position = centerPos
	print("center these guts")
