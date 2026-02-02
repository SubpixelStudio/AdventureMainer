extends TouchScreenButton

@export var sound_bus_name: String = "Master"

var enabled: bool = true
var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(sound_bus_name)
	_apply_state()

func _apply_state() -> void:
	AudioServer.set_bus_mute(bus_index, !enabled)
	if enabled:
		texture_normal = preload("res://Assets/UI/mobile-controls-1/Sprites/Icons/Default/icon_sound.png")
	else:
		texture_normal = preload("res://Assets/UI/mobile-controls-1/Sprites/Icons/Default/icon_music_disabled.png")
func _on_pressed() -> void:
	enabled = !enabled
	_apply_state()
