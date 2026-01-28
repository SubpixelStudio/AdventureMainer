class_name SoundEffect
extends AudioStreamPlayer2D

static func play_audio(sound: AudioStream,parent: Node,position: Vector2) -> void:
	var s := SoundEffect.new()
	s.stream = sound
	s.global_position = position
	parent.add_child(s)
	s.play()
	s.finished.connect(s.queue_free)

static func play_music(sound:AudioStream,parent:Node,position:Vector2,name_sound:String) -> void:
	var s := SoundEffect.new()
	s.name = name_sound
	s.stream = sound
	s.global_position = position
	parent.add_child(s)
	s.play()
	s.finished.connect(s.play)
