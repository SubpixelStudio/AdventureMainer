class_name QuestManager
extends Node


@export var mainQuest:Quest

##lista de quests
@export var questList:Array[Quest]

signal mission_setted(quest:Quest)

func quest_delivery(quest:Quest, main_quest:bool):
	questList.append(quest)
	quest.quest_completed.connect(complete_quest)
	
	if main_quest:
		if mainQuest: mainQuest.completar_quest()
		mainQuest = quest
		mission_setted.emit(mainQuest)

##isso é para contabilizar as quests.
##delovery_id é o id do tipo de item
##action_type é o tipo: 0 é derrotar, 1 é coletar, 2 é conversar.
func recive_count(delivery_id:String, action_type:int):
	
	for quest in questList:
		if quest.current_state != action_type: continue
		var count:bool = false
		for id in quest.object_id:
			if delivery_id == id: 
				count = true
				break
		if count:
			quest.count(1)
			mission_setted.emit(mainQuest)

func complete_quest(quest:Quest):
	questList.erase(quest)
	if quest == mainQuest:
		mainQuest = null
		mission_setted.emit(null)

#isso deve deletar as quest que estão livres
func clean_quest():
	for i in range(questList.size() - 1, -1, -1):
		if not is_instance_valid(questList[i]):
			questList.remove_at(i)
