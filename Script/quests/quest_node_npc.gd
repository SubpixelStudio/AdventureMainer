##este node é usando para setar a proxima quest ou proxima ação no npc
##quando uma quest acaba
extends Node
class_name NpcQuestNode


@export_category("interação")
@export var new_dialogue:NpcDialogueResource
##o valor do index do dialogo atual(ou que vai começar)
@export var current_interaction:int = 0

@export_category("quests")
##a quest que será dada
@export var new_quest:Quest
##se a quest é uma principal
@export var main_give_quest:bool = false
##se a queste será entregue
@export var give_quest:bool = true
##o index do dialogo que será entregue.(ele entrega no fim deste dialogo)
@export var delivery_dialogue_index:int = 0

@export var next_quest:NodePath

##sinal emitido quando essa quest ficar disponivel para o jogador
signal prologue_quest

func start_new_quest() -> void:
	if not get_parent() is Generic_NPC:
		push_error("quest_Node deve ser filha de um Generic_NPC")
		return
	if not new_quest or not new_dialogue: 
		push_error("quest_Node deve ter um recurso Quest ou um dialogo")
		return
	var self_npc:Generic_NPC = get_parent()
	
	self_npc.set_dialogue(new_dialogue,current_interaction)
	self_npc.set_quest(new_quest,main_give_quest,give_quest,delivery_dialogue_index)
	
	self_npc.next_quest = self.next_quest
	
	prologue_quest.emit()
