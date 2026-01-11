extends CharacterBody2D

@export var indice_missao := 0
@export var world: WorldManager

@export var ui : Control
@export var label_mission : Objective
@export var input : Sprite2D
var jogador_perto := false

func _ready():
	ui.get_node("Color").visible = false

func _process(_delta):
	if jogador_perto and Input.is_action_just_pressed("interagir"):
		ui.get_node('Color').visible = true
		label_mission.iniciar_missao(Global.indice)
		if label_mission.frase_atual >= label_mission.frases.size():
			terminar_leitura()
	
	if jogador_perto == true:
		$Input.visible = true
		$Input.play("idle")
	else:
		$Input.visible = false

func terminar_leitura():
	ui.get_node('Color').visible = false
	world.leitura_concluida()
	queue_free()

func _on_AreaMission_body_entered(body):
	if body.is_in_group("Player"):
		jogador_perto = true

func _on_AreaMission_body_exited(body):
	if body.is_in_group("Player"):
		jogador_perto = false
		ui.visible = false
