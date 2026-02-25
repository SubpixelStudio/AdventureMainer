extends Control

@export var main_button : Array[Button]

func _ready() -> void:
	
	# Esconde todas as páginas
	for page in $Main.get_children():
		page.visible = false
	
	# Conecta todos os botões
	for btn in main_button:
		btn.pressed.connect(on_press.bind(btn))


func on_press(btn:Button) -> void:

	# Esconde tudo
	for page in $Main.get_children():
		page.visible = false
	
	# Procura página com mesmo nome do botão
	var target = $Main.get_node_or_null(NodePath(btn.name))
	
	if target:
		target.visible = true
	else:
		push_warning("Página não encontrada para: " + btn.name)


func _on_b_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
