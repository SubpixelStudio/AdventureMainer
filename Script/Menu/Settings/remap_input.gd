extends Button
class_name RemapButton

var action : String
var event_index:int = 0

##gambirra para ligar o pop_up
@onready var pop_up_assigned:Node = $"../../../../key_pop_up_control"

func _init() -> void:
	toggle_mode = true

func _ready() -> void:
	set_process_unhandled_input(false)

func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if button_pressed:
		for child in get_parent().get_children():
			if child != self and child is Button:
				child.focus_mode = Control.FOCUS_NONE
		text = "Awaiting Input"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		button_pressed = false
		release_focus()
		_update_text()
		return
	
	if event.is_pressed() and event is InputEventKey and event.keycode == KEY_DELETE:
		var empty_event = InputEventKey.new()
		empty_event.keycode = KEY_NONE
		InputHelper.remap(action, empty_event, event_index)
		button_pressed = false
		release_focus()
		_update_text()
		return
	
	if event.is_pressed():
		var remaped = InputHelper.remap(action, event, event_index)
		if not remaped: alert()
		button_pressed = false
		release_focus()
		_update_text()

func alert():
	pop_up_assigned.modulate.a = 1.0
	pop_up_assigned.visible = true
	
	var visible_time:float = 1.0
	var duration_tween:float = 0.5
	
	get_tree().create_timer(visible_time).timeout.connect(func():
		var tween = create_tween()
		tween.tween_property(pop_up_assigned, "modulate:a", 0.0, duration_tween)
		tween.tween_callback(func():
			pop_up_assigned.visible = false
			pop_up_assigned.modulate.a = 1.0
		)
	)


func _update_text():
	text = InputHelper.get_event_from_action(action,event_index)
