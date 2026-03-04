extends State

func _start():
	print('Entrei no Run')
	manager.state_machine.travel("Run")


func _run(delta: float) -> void:
	print('Continuo em Run')
	var player: Player = manager.owner_node
	var input_vector: Vector2 = player.input_vector
	
	# Atualiza velocity
	player.velocity = input_vector * player.speed
	
	# Atualiza o BlendSpace do Run
	if input_vector != Vector2.ZERO:
		manager.anim_tree.set("parameters/Run/blend_position", input_vector)
		player.last_direction = input_vector.normalized()
	else:
		manager.anim_tree.set("parameters/Idle/blend_position", player.last_direction)
		manager.switch_state('Idle')

func _end():
	print('Terminei o Run')
