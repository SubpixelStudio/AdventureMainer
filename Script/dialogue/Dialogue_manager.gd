##um nó feito para gerenciar a UI
extends CanvasLayer
class_name UserInterfaceManager

@onready var mission_panel: ColorRect = %MissionPanel
@onready var mission_text: Label = mission_panel.get_node("MissionText")


##painel de dialogos
@onready var painel_dialogue:Control = $MissionScreen/DialogPanel
##label de dialogos
@onready var label_dialogue:Label = $MissionScreen/DialogPanel/DialogText


@export var quest_manager:QuestManager

##player da cena
@export var player_target:Player

##esse npc deve ser setado pelo player
var npc_target:Generic_NPC

var ocultado: bool = true

func _ready() -> void:
	ocultar(true)
	quest_manager.mission_setted.connect(_set_mission_description)
	
	_set_mission_description(quest_manager.mainQuest)
	painel_dialogue.visible = false

	###====remover depois, apenas para fins de texte=====##
	npc_getter(npc_target)
	###==================================================##
	
	player_target.interacted_npc.connect(npc_getter)

func npc_getter(npc:Generic_NPC):
	if not npc: return
	#desconecta o npc anterior
	if npc_target:
		npc_target.actor_speak.disconnect(set_dialogue_text)
		npc_target.start_dialogue.disconnect(start_dialogue)
		npc_target.end_dialogue.disconnect(end_dialogue)
		
		#desconecta a quest do npc a quest manager se existir
		if quest_manager: npc_target.quest_delivered.disconnect(quest_manager.quest_delivery)
	
	#seta e conecta o npc atual
	npc_target = npc
	npc_target.actor_speak.connect(set_dialogue_text)
	npc_target.start_dialogue.connect(start_dialogue)
	npc_target.end_dialogue.connect(end_dialogue)
	
	#conecta a quest do npc a quest manager se existir
	if quest_manager: npc_target.quest_delivered.connect(quest_manager.quest_delivery)
	
	
	npc_target.interaction()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			$Menu.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			$Menu.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ocultar"):
		ocultar(ocultado)
	
func _set_mission_description(quest:Quest):
	if quest:
		var text:String = quest.description
		if quest.show_counter:
			text += "\n\n" + str(quest.quantidade_atual)+ " / " + str(quest.quantidade_max)
			
		mission_text.text = text
	else:
		mission_text.text = "..."

func ocultar(_sim: bool) -> void:
	
	mission_text.visible = not mission_text.visible
	mission_panel.anchor_left = 0.687 if mission_text.visible else 1.0
	ocultado = mission_text.visible


func start_dialogue(text_start:String = ""):
	painel_dialogue.visible = true
	label_dialogue.text = text_start

func end_dialogue(time:float = 0):
	await get_tree().create_timer(time).timeout
	painel_dialogue.visible = false
	label_dialogue.text = ""

func set_dialogue_text(text:String):
	#print("texto setado: ",text)
	label_dialogue.text = text
