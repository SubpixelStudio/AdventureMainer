extends State

func _start():
	print('Entrei no Run')


func _run(delta: float) -> void:
	print('Continuo em Run')
	var player: Player = manager.owner_node
	var input_vector: Vector2 = Input.get_vector("A", "D", "W", "S").normalized()
	
	player.velocity = input_vector * player.speed
	
	if input_vector == Vector2.ZERO:
		player.last_direction = input_vector.normalized()
		manager.switch_state('Idle')


func _end():
	print('Terminei o Run')
