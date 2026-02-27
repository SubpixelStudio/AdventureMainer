extends State

func _start():
	print('Entrei no Idle')


func _run(delta: float) -> void:
	print('Continuo em Idle')


func _end():
	print('Terminei o Idle')
