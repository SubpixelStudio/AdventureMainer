extends State

func _start():
	print('Entrei no Run')


func _run(delta: float) -> void:
	print('Continuo em Run')
	if Input.is_action_just_released("W"):
		manager.switch_state('Idle')


func _end():
	print('Terminei o Run')
