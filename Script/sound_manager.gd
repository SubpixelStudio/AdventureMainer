extends Node
const music: Array[AudioStream] = [
	preload("res://Assets/Sound/Main Theme.mp3"),
	preload("res://Assets/Sound/Battle theme.wav"),
	preload("res://Assets/Sound/Ville Theme.wav"),
	preload("res://Assets/Sound/Floresta theme.mp3")
]
var current_music_node: AudioStreamPlayer2D
enum {NORMAL,COMBAT,VILLAGE,FOREST}
var current_state = NORMAL

#variáveis de acesso
@export var player:CharacterBody2D
@export var world :Node
@onready var label:Label = world.get_node("CanvasLayer/Label")
@onready var timer:Timer = label.get_node("Timer")
func _ready() -> void:
	timer.timeout.connect(timeout_func)
	play_world_music(0, player.position,"Normal")

func _physics_process(_delta: float) -> void:
	var nome_music:String = str(current_state)
	if current_state:
		play_world_music(current_state,player.position,nome_music)

func play_world_music(music_index: int, pos: Vector2, song_name: String):
	if current_music_node:
		# Não tocar a mesma música se já tiver tocando
		if current_music_node.name == song_name: 
			return
		# Destruir a música que está tocando pra tocar a nova musica
		current_music_node.queue_free()
	
	current_music_node = SoundEffect.play_music(music[music_index], self, pos, song_name)

func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		current_state = VILLAGE
		label.text = "Alvelas Village"
		timer.start()

func _on_body_exited(body) -> void:
	if body.is_in_group("Player"):
		current_state = FOREST
		label.text = "Forest"
		timer.start()

func timeout_func() -> void:
	label.text = ""
