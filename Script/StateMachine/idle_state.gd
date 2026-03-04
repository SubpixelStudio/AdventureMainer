extends State

func _start():
	print('Entrei no Idle')
	manager.state_machine.travel("Idle")


func _run(delta: float) -> void:
	print('Continuo em Idle')
	var player: Player = manager.owner_node
	if player.input_vector != Vector2.ZERO:
		manager.state_machine.travel("Run")
		player.last_direction = player.input_vector.normalized()
		manager.switch_state('Run')


func _end():
	print('Terminei o Idle')
