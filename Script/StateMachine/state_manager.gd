extends Node

class_name StateManager

## Caminho do AnimationTree desejado
@export var animation_tree_path: NodePath

@export var array_states: Array[State]
@export var initial_state: String

# Pega o AnimationTree e captura o Tree Root (pai das anims)
@onready var anim_tree: AnimationTree = get_node(animation_tree_path)
@onready var state_machine = anim_tree.get("parameters/playback")

var owner_node: Node
var current_state: State
var array_names: Array[String]

func _ready() -> void:
	# Node Raiz
	owner_node = get_parent() as Node

	if not self:
		push_error("SI MESMO NAO DEFINIDO")
		return
	
	# Captura os filhos do BaseState e adiciona no Array
	array_states.clear()
	for child in self.get_children():
		if child is State:
			array_states.append(child)
			array_names.append(child.name)
			print(child, ' - ', child.name)
	
	if not array_states.size():
		push_error("Nenhum state encontrado dentro de base_state")
		return
	
	if not initial_state:
		initial_state = array_states[0].name
	
	switch_state(initial_state)


func _process(delta: float) -> void:
	if not current_state: return
	current_state._run(delta)


func switch_state(str_state: String) -> void:
	var id = array_names.find(str_state)
	var new_state: State = array_states[id]
	
	# Se for o mesmo estado, quebra a func
	if new_state == current_state: 
		return
	
	# Senao, termina o estado atual e troca para outro
	if current_state:
		current_state._end()
	
	current_state = new_state
	current_state.actor = owner_node # ref ao node raiz
	current_state.manager = self # ref ao proprio manager
	current_state._start()
