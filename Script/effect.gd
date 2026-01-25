class_name SoundManager
extends AudioStreamPlayer2D

func play_sound(sound: AudioStream) -> void:
	stream = sound
	play()
	await finished
	queue_free()
