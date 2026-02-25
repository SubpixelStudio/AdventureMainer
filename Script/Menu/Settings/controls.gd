extends Control

##o texto da label e o nome do action do mapa de entrada
@export var actions_list:Array[ActionData]

##caminho onde serão colocados os Remap_containers
@export var path_to_remap_container:NodePath

var target_path:Node

var remap_scene:PackedScene = preload("res://Cenas/Menu/remap_container.tscn")

func _ready() -> void:
	$key_pop_up_control.modulate.a = 0.0
	if not path_to_remap_container or not has_node(path_to_remap_container): 
		push_error("caminho de path_to_remap_container não encontrado")
		return
	target_path = get_node(path_to_remap_container)
	clean_remaps_Container(target_path)
	
	if actions_list.is_empty(): return
	for i in actions_list:
		if not i: continue
		var new_obj:RemapContainer = remap_scene.instantiate()
		new_obj.label_text = i.name
		
		new_obj.button_text = InputHelper.get_event_from_action(i.action_name)
		new_obj.action_name = i.action_name
		new_obj.event_index = 0
		
		new_obj.button_text_2 = InputHelper.get_event_from_action(i.action_name, 1)
		new_obj.action_name_2 = i.action_name
		new_obj.event_index_2 = 1
	
		target_path.add_child(new_obj)

func clean_remaps_Container(node:Node):
	if node.get_children().is_empty(): return
	for i in node.get_children():
		if i is RemapContainer:
			i.queue_free()
