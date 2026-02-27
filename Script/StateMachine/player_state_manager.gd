extends StateManager

## Favor nao sobrescrever _ready(), _process() e switch_state()

enum PlayerState {
	IDLE,
	RUN
}

# Func p/ lidar com os states e chamar o switch_state() 
func _handle_states(current_state: State) -> void:
	print(array_states)
	if Input.is_action_pressed("W"): # RUN
		switch_state(array_states[1])
		pass
	else: # IDLE
		switch_state(array_states[0])
		pass
		#switch_state()
