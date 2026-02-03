class_name QuestManager
extends Node

@export var quest: Quest

func iniciar_quest(id: int) -> void:
	var q = quest.quests[id]
	if q.ativa:
		return
	quest.iniciar(id)


func inimigo_morto() -> void:
	quest.inimigo_morto()


func _get_quest_ativa() -> int:
	for id in quest.quests:
		if quest.quests[id].ativa:
			return id
	return -1
