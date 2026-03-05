extends Entities
class_name Player

const NORMAL_ANIM_SPEED: float = .6
const ATTACK_ANIM_SPEED: float = 1

@export_group("Properties")
@export var speed: float = 200
@export var attack_cooldown: float = 0.4
@export var damage: int 
##tempo necessario para ativar o heavy attack
@export var hold_to_heavy:float = 0.3
@export_group("Nodes")
@export var world: WorldManager
@export var soundManager:Node
@onready var anim: AnimationPlayer = $Anim
@onready var attack_area: Area2D = $AttackArea

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")


var last_direction: Vector2 = Vector2.DOWN
var mira: Sprite2D = null



# ------------------------------
# SISTEMA DE INTERAÇÃO
# ------------------------------
## a area de interação do player
@onready var area_interact:Area2D =  $Area2D
##isso deve rodar toda vez e achar o npc mais perto(ainda sem utilidade)
##não adicionei nada ao codigo para não processar sobrecarregar de funções
var npc_interact_tartget:Generic_NPC

## sinal emite o npc que interagiu
signal interacted_npc(npc:Generic_NPC)

signal attack_pressed

# -------------------------------------------------

func _ready() -> void:
	anim_tree.active = true

func _physics_process(_delta: float) -> void:
	input_vector = Input.get_vector("A", "D", "W", "S").normalized()
	
	is_attacking = Input.is_action_pressed("attack")
	
	if input_vector != Vector2.ZERO:
		#state_machine.travel("run")
		anim_tree.set("parameters/Run/blend_position", input_vector)
	else:
		#state_machine.travel("idle")
		anim_tree.set("parameters/Idle/blend_position", last_direction)
	
	if is_dead:
		return
	interact_update()
	
	move_and_slide()

func interact_update():
	
	if not area_interact: return
	if Input.is_action_just_pressed("interagir"):
		var bodies = area_interact.get_overlapping_bodies()
		var near_npc:Generic_NPC
		var shortest_distance = INF
		for body in bodies:
			if body is Generic_NPC:
				# Calcula a distância entre seu personagem e o NPC
				var distance = global_position.distance_to(body.global_position)
				
				# Verifica se é o NPC mais próximo encontrado até agora
				if distance < shortest_distance:
					shortest_distance = distance
					near_npc = body
		if near_npc:
			##aqui é o npc mais perto
			interacted_npc.emit(near_npc)
		else:
			##aqui é quando não acha nenhum npc
			pass
			print("nenhum npc achado")

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		body.knockback = position.direction_to(body.position) * 500

func _unhandled_input(_event: InputEvent) -> void:
	input_vector = Input.get_vector("A", "D", "W", "S").normalized()
	print(input_vector)

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Tree"):
		if area.has_method("take_damage"):
			area.take_damage(1)
