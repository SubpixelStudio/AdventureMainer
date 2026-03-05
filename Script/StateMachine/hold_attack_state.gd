extends State

var time:float = 0.0

var heavyAttack:bool = false

func _start() -> void:
	heavyAttack = false
	time = 0

func _run(delta: float) -> void:
	var entities: Entities = actor
	if not heavyAttack: time+=delta
	if time>= entities.hold_to_heavy:
		heavyAttack = true
	
	if entities.is_attacked: return
	
	if heavyAttack:
		manager.switch_state("HeavyAttack")
	else:
		manager.switch_state("LightAttack")
	

func _end() -> void: pass
