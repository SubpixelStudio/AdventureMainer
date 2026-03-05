extends State

func _start():
	manager.state_machine.travel("Idle")


func _run(delta: float) -> void:
	var entity: Entities = actor
	if entity.input_vector != Vector2.ZERO:
		manager.state_machine.travel("Run")
		entity.last_direction = entity.input_vector.normalized()
		manager.switch_state('Run')


func _end():
	pass
