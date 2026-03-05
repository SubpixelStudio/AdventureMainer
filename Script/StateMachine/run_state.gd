extends State

@export var WALKING_SOUND:AudioStream = preload("res://Assets/Sound/Step.mp3")
var sound:AudioStreamPlayer2D

func _start():
	manager.state_machine.travel("Run")


func _run(_delta: float) -> void:
	var entities: Entities = actor
	var input_vector: Vector2 = entities.input_vector
	
	# Atualiza velocity
	entities.velocity = input_vector * entities.speed
	
	# Atualiza o BlendSpace do Run
	if input_vector != Vector2.ZERO:
		manager.anim_tree.set("parameters/Run/blend_position", input_vector)
		entities.last_direction = input_vector.normalized()
	else:
		manager.anim_tree.set("parameters/Idle/blend_position", entities.last_direction)
		manager.switch_state('Idle')
	
	if entities.is_attacked:
		manager.switch_state("HoldAttack")
	
	if sound and not sound.playing: sound = SoundEffect.play_sound(WALKING_SOUND,self,entities.global_position)
	
func _end():
	pass
