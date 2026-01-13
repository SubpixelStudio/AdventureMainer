extends CharacterBody2D

@export var mission_screen: Control
@export var dialog_text: Objective

@onready var world: WorldManager = get_tree().current_scene
@onready var input: AnimatedSprite2D = $Input
@onready var dialog_panel: ColorRect = mission_screen.get_node("DialogPanel")

var jogador_perto: bool = false


func _ready() -> void:
	dialog_panel.visible = false

func _process(_delta: float) -> void:
	if jogador_perto and Input.is_action_just_pressed("interagir"):
		dialog_panel.visible = true
		dialog_text.iniciar_missao(Global.indice)
		if dialog_text.frase_atual >= dialog_text.frases.size():
			print("terminar leitura")
			terminar_leitura()
	
	if jogador_perto == true:
		input.visible = true
		input.play("idle")
	else:
		input.visible = false

func terminar_leitura() -> void:
	dialog_panel.visible = false
	world.leitura_concluida()
	queue_free()

func _on_AreaMission_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = true

func _on_AreaMission_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = false
		mission_screen.visible = false
