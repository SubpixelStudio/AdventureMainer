extends State

func _start():
	print('Entrei no Idle')


func _run(delta: float) -> void:
	print('Continuo em Idle')
	
	if Input.is_action_pressed('W'):
		manager.switch_state('Run')
	
	

func _end():
	print('Terminei o Idle')
