extends CharacterBody2D

@export var mission_screen: Control
@export var dialog_text: Objective

@onready var world: WorldManager = get_tree().current_scene
@onready var input_icon: AnimatedSprite2D = $Input
@onready var dialog_panel: ColorRect = mission_screen.get_node("DialogPanel")

var jogador_perto: bool = false
var dialogo_ativo: bool = false


func _ready() -> void:
	dialog_panel.visible = false
	input_icon.visible = false

	if world and GameData.autoiniciar_missao:
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
	world.leitura_concluida()
	if world:
		world.leitura_concluida()

	queue_free()

func _atualizar_input_icon() -> void:
	input_icon.visible = jogador_perto
	input_icon.get_node("Label").visible = OS.get_name() == "Android"
	if jogador_perto and input_icon.animation != "PC":
		if OS.get_name() == "Android":
			input_icon.play("Mobile")
			input_icon.scale = Vector2(0.5,0.5)
		input_icon.play("PC")

func _cancelar_interacao() -> void:
	dialogo_ativo = false
	dialog_panel.visible = false
	mission_screen.visible = false
	dialog_text.resetar_dialogo()
	
	if world:
		world.cancelar_missao()


# =============================
# AREA DE DETECÇÃO
# =============================
func _on_AreaMission_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = true

func _on_AreaMission_body_exited(body: Node2D) -> void:
	#if body.is_in_group("Player"):
		#jogador_perto = false
		#mission_screen.visible = false
	if not body.is_in_group("Player"):
		return
	
	jogador_perto = false
	
	_cancelar_interacao()
