class_name ParryEffect extends Node2D

@onready var parried_sprite: AnimatedSprite2D = $ParriedSprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var dust_particles: CPUParticles2D = $DustParticles
@onready var unfreeze_timer: Timer = $UnfreezeTimer
@onready var flashbang: CanvasLayer = $Flashbang

signal unfrozen


func _ready() -> void:
	particles.one_shot = true
	particles.emitting = false
	dust_particles.emitting = false
	flashbang.visible = false

func start_parry():
	particles.restart()
	dust_particles.restart()
	parried_sprite.play("parried")
	get_tree().paused = true
	flashbang.visible = true
	
	unfreeze_timer.start()

func unfreeze():
	get_tree().paused = false
	flashbang.visible = false
	unfrozen.emit()
