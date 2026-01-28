class_name SoundEffect
extends AudioStreamPlayer2D


static func play_sound(audio_stream: AudioStream, parent: Node, pos: Vector2) -> AudioStreamPlayer2D:
	var sound: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sound.stream = audio_stream
	sound.global_position = pos
	parent.add_child(sound)
	sound.finished.connect(sound.queue_free)
	
	sound.play()
	
	return sound

## Músicas também são sons, então é so chamar o play_sound e trocar o nome deles (Foi implementado dessa forma aí)
static func play_music(audio_stream: AudioStream, parent: Node, pos: Vector2, song_name: String) -> AudioStreamPlayer2D:
	var music: AudioStreamPlayer2D = SoundEffect.play_sound(audio_stream, parent, pos)
	music.name = song_name
	
	return music
