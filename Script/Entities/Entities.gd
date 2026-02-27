extends CharacterBody2D
class_name Entities

##vida total da entidade
@export var max_life:int = 100
##vida atual da entidade
@export var life:int = 100

##stamina total da entidade
@export var max_stamina: int = 100
##stamina atual da entidade
@export var stamina: int = 100

##mana total da entidade
@export var max_mana: int = 100
##mana atual da entidade
@export var mana: int = 100


##id da entidade
@export var id:String = ""

##valor que dividirá o dano recebido
@export var block_multiplier:float = 0.5
##janela de tempo do parry
@export var parry_block_timer:float = 0.1

var block:bool = false
var parry_blocked:bool = false

var is_dead:bool = false

var is_attacked:bool = false

signal damaged(value:int)
signal blocked
signal died

func _received_heal(value:int):
	life+=value
	if life >= max_life : life=max_life

func _received_mana(value:int):
	mana+=value
	if mana >= max_mana : mana=max_mana

func _received_stamina(value:int):
	stamina+=value
	if stamina >= max_stamina : stamina=max_stamina

##função de recebimento do dano real
func _received_damage(value:int):
	var damage_value:int
	is_attacked_logic()
	if parry_blocked:
		blocked.emit()
		damage_value = 0
	elif block:
		blocked.emit()
		damage_value = int(block_multiplier * value)
	else:
		damage_value = value
		
	life-= damage_value
	damaged.emit(value)
	
	if life <= 0: _die()

##função de recebimento do dano real
func is_attacked_logic():
	is_attacked = true
	await get_tree().create_timer(0.2).timeoutmer
	is_attacked = false

##função de bloquear ataque
func _block_system():
	block = true
	parry_blocked = true
	await get_tree().create_timer(parry_block_timer).timeoutmer
	parry_blocked = false

##função de morte instantanea
func _die():
	died.emit()
	is_dead=true
