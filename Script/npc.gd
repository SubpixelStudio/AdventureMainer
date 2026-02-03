extends CharacterBody2D

@export var mission_screen: Control
@export var dialog_text: Objective
@export var quest_manager: QuestManager
@export var quest_id: int

@onready var input_icon: AnimatedSprite2D = $Input
@onready var dialog_panel: ColorRect = mission_screen.get_node("DialogPanel")

var jogador_perto: bool = false
var dialogo_ativo: bool = false


func _ready() -> void:
	print(quest_manager)
	dialog_panel.visible = false
	input_icon.visible = false


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
			_avancar_ou_finalizar_dialogo()


func _iniciar_dialogo() -> void:
	dialogo_ativo = true
	dialog_panel.visible = true
	
	dialog_text.resetar_dialogo()
	dialog_text.iniciar_missao(quest_id)


func _avancar_ou_finalizar_dialogo() -> void:
	if dialog_text.frase_atual >= dialog_text.frases.size() - 1:
		_finalizar_dialogo()
	else:
		dialog_text.avancar_dialogo()


func _finalizar_dialogo() -> void:
	dialogo_ativo = false
	dialog_panel.visible = false
	if quest_manager:
		quest_manager.iniciar_quest(quest_id) 

	queue_free()



# =============================
# INPUT ICON
# =============================
func _atualizar_input_icon() -> void:
	input_icon.visible = jogador_perto
	
	if not jogador_perto:
		return
	
	var is_mobile := OS.get_name() == "Android"
	input_icon.get_node("Label").visible = is_mobile
	
	if is_mobile:
		if input_icon.animation != "Mobile":
			input_icon.play("Mobile")
			input_icon.scale = Vector2(0.5, 0.5)
	else:
		if input_icon.animation != "PC":
			input_icon.play("PC")
			input_icon.scale = Vector2.ONE


# =============================
# CANCELAMENTO
# =============================
func _cancelar_interacao() -> void:
	dialogo_ativo = false
	dialog_panel.visible = false
	mission_screen.visible = false
	dialog_text.resetar_dialogo()


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
