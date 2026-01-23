extends CharacterBody2D

@export var mission_screen: Control
@export var dialog_text: Objective

@onready var world := get_tree().current_scene as WorldManager
@onready var input_icon: AnimatedSprite2D = $Input
@onready var dialog_panel: ColorRect = $"../Canvas/MissionScreen/DialogPanel"

var jogador_perto := false
var dialogo_ativo := false


func _ready() -> void:
	dialog_panel.visible = false
	input_icon.visible = false

	if GameData.autoiniciar_missao and world:
		world.leitura_concluida()


func _process(_delta: float) -> void:
	_atualizar_input_icon()
	_processar_interacao()


func _processar_interacao() -> void:
	if not jogador_perto:
		return

	if Input.is_action_just_pressed("interagir"):
		if not dialogo_ativo:
			_iniciar_dialogo()
		else:
			_verificar_fim_dialogo()


func _iniciar_dialogo() -> void:
	dialogo_ativo = true
	dialog_panel.visible = true
	dialog_text.iniciar_missao(GameData.missao_atual)


func _verificar_fim_dialogo() -> void:
	if dialog_text.frase_atual >= dialog_text.frases.size():
		_finalizar_dialogo()


func _finalizar_dialogo() -> void:
	dialogo_ativo = false
	dialog_panel.visible = false
	if world:
		world.leitura_concluida()

	queue_free()


func _atualizar_input_icon() -> void:
	input_icon.visible = jogador_perto

	if jogador_perto and input_icon.animation != "idle":
		input_icon.play("idle")


# =============================
# AREA DE DETECÇÃO
# =============================

func _on_AreaMission_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = true


func _on_AreaMission_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	jogador_perto = false

	_cancelar_interacao()


func _cancelar_interacao() -> void:
	dialogo_ativo = false
	dialog_panel.visible = false
	mission_screen.visible = false
	dialog_text.resetar_dialogo()

	if world:
		world.cancelar_missao()
