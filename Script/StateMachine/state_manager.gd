extends Node

class_name StateManager

@export var base_state: Node
@export var array_states: Array[State]
@export var initial_state: State

var owner_node: Node
var current_state: State

func _ready() -> void:
	# Node Raiz
	owner_node = get_parent() as Node

	if not base_state:
		push_error("base_state nao definido")
		return
	
	# Captura os filhos do BaseState e adiciona no Array
	array_states.clear()
	for child in base_state.get_children():
		if child is State:
			array_states.append(child)
			print(child)
	
	if not array_states.size():
		push_error("Nenhum state encontrado dentro de base_state")
		return
	
	if not initial_state:
		initial_state = array_states[0]
	
	switch_state(initial_state)


func _process(delta: float) -> void:
	if current_state:
		current_state._run(delta)
	_handle_states(current_state)


func switch_state(new_state: State) -> void:
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


# P/ lidar com os States
func _handle_states(current_state):
	pass
