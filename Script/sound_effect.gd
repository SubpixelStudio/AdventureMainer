class_name SoundEffect
extends AudioStreamPlayer2D

static func play_audio(sound: AudioStream,parent: Player,position: Vector2) -> void:
	var s := SoundEffect.new()
	s.stream = sound
	s.global_position = position
	parent.add_child(s)
	s.play()
	s.finished.connect(s.queue_free)
