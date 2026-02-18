class_name Quest
extends Resource

@export var missionName:String
@export_multiline var description:String

@export_enum("DERROTAR","COLETAR","CONVERSAR") var current_state
@export var object_id:Array[String]
@export var quantidade_max:int = 10
@export var quantidade_atual:int = 0

@export var show_counter:bool

signal counted(quest:Quest)
signal quest_completed(quest:Quest)

func count(value:int = 1):
	quantidade_atual+=value
	if quantidade_atual >= quantidade_max:
		completar_quest()
	else:
		counted.emit(self)
	print("contado: ", quantidade_atual)

##emite um sinal de quest completada
func completar_quest():
	print("completado ")
	quest_completed.emit(self)
	
