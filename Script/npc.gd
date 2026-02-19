extends CharacterBody2D
class_name Generic_NPC

@export_category("configuração")
@export var area_interaction:Area2D
@export_category("interação")
@export var dialogue:NpcDialogueResource
##o valor do index do dialogo atual(ou que vai começar)
@export var current_interaction:int = 0
@export_category("quests")
##a quest que será dada
@export var quest_to_give:Quest
##se a quest é uma principal
@export var main_give_quest:bool = false
##se a queste será entregue
@export var give_quest:bool = true
##o index do dialogo que será entregue.(ele entrega no fim deste dialogo)
@export var delivery_dialogue_index:int = 0

##o caminho do node da proxima quest
##obrigatório ser um NpcQuestNode.
##obs: é um NodePath pois pode futuramente da erro de depedencia
@export var next_quest:NodePath

@onready var input_icon: AnimatedSprite2D = $Input




var jogador_perto: bool = false
var dialogo_ativo: bool = false
var dialogo_completado:bool = false

##isso emite oque fala
signal actor_speak(text:String)
##isso emite quando o npc termina a fala
signal end_actor
##isso emite quando o npc inicia a fala
signal start_dialogue
##isso emite quando o npc a fala é interrompida(podendo ser por termino)
signal end_dialogue(time:float)
##isso emite quando ele esta entregando uma quest
signal quest_delivered(quest:Quest,main_give_quest:bool)

signal cur_quest_completed

func _ready() -> void:
	if OS.get_name() == "Android":
		$Input.global_position.y = -42.0
	else:
		$Input.global_position.y = -24
	if area_interaction: 
		area_interaction.body_entered.connect(_on_AreaMission_body_entered)
		area_interaction.body_exited.connect(_on_AreaMission_body_exited)
	
	input_icon.visible = false

func _process(_delta: float) -> void:
	_atualizar_input_icon()

func interaction() -> void:
	#condições ant crash
	if not dialogue: return
	if dialogue.actor_lines.size() == 0: return
	
	#condição ant bug
	if (
		current_interaction >= dialogue.actor_lines.size()
		and not dialogo_ativo
	): return
	
	#codigo de entrega de quest
	if (
		quest_to_give 
		and give_quest 
		and current_interaction == delivery_dialogue_index+1
		):
		var quest_to_emit:Quest = quest_to_give.duplicate()
		quest_delivered.emit(quest_to_emit,main_give_quest)
		quest_to_emit.quest_completed.connect(self.quest_completed)
	
	#condições de inicio e fim do dialogo
	if not dialogo_ativo: _iniciar_dialogo()
	if (
		current_interaction >= dialogue.actor_lines.size()
		and dialogo_ativo
	): 
		_finalizar_dialogo()
		_end_actor()
		return
	
	#isso é que faz as coisas acontecerem
	
	
	
	#codigo do dialogo 
	var current_text:String
	if current_interaction < dialogue.actor_lines.size():
		current_text = dialogue.actor_lines[current_interaction]
	#codigo de emissão e proximo dialogo
	current_interaction+=1
	actor_speak.emit(current_text)

func _iniciar_dialogo():
	dialogo_ativo = true
	start_dialogue.emit()

func _finalizar_dialogo(time:float = 0) -> void:
	dialogo_ativo = false
	end_dialogue.emit(time)
	

func _end_actor():
	dialogo_completado = true
	end_actor.emit()

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
	if dialogo_completado: return
	current_interaction = 0
	actor_speak.emit("ei, volte!, eu estava falando!")
	
	_finalizar_dialogo(2.0)

func quest_completed(_quest:Quest):
	cur_quest_completed.emit()
	
	if not next_quest or not has_node(next_quest): return
	var node = get_node(next_quest)
	if not node is NpcQuestNode: 
		push_error("o next_quest de ",name," não é um NpcQuestNode")
		return
	node.start_new_quest()

func set_quest(quest:Quest,is_main:bool = false,will_give_in_end:bool = true,ddi:int = 0) -> void:
	quest_to_give = quest
	main_give_quest = is_main
	give_quest = will_give_in_end
	delivery_dialogue_index = ddi

func set_dialogue(dilogue:NpcDialogueResource, start_index:int) -> void:
	current_interaction = start_index
	dialogue = dilogue

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
