extends Control

@export var button:Array[OptionButton]
@export var check_vsync:CheckBox
@export var dict:Dictionary = {
	# 0 → Resolução
	0: [
		Vector2i(1920,1080),
		Vector2i(1680,1050),
		Vector2i(1600,900),
		Vector2i(1440,900),
		Vector2i(1366,768),
		Vector2i(1280,720)
	],

	# 1 → Modo de janela
	1: [
		DisplayServer.WINDOW_MODE_WINDOWED,
		DisplayServer.WINDOW_MODE_FULLSCREEN,
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	],

	# 2 → FPS
	2: [
		30,
		60,
		120,
		144,
		240,
		0 # 0 = ilimitado
	]
}


func _ready() -> void:
	
	# POPULA OPTION BUTTONS
	for i in range(button.size()):
		
		button[i].clear()
		
		for x in range(dict[i].size()):
			
			var value = dict[i][x]
			var text := ""
			
			match i:
				0:
					text = str(value.x) + "x" + str(value.y)
				
				1:
					match value:
						DisplayServer.WINDOW_MODE_WINDOWED:
							text = "Janela"
						DisplayServer.WINDOW_MODE_FULLSCREEN:
							text = "Fullscreen"
						DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
							text = "Fullscreen Exclusivo"
				
				2:
					if value == 0:
						text = "Ilimitado"
					else:
						text = str(value) + " FPS"
			
			button[i].add_item(text)
		
		button[i].item_selected.connect(on_option_selected.bind(i))
	
	
	# CONECTA CHECKBOX VSYNC
	check_vsync.toggled.connect(on_vsync_toggled)


# ==========================================
# OPTION BUTTONS
# ==========================================

func on_option_selected(item_index:int, button_index:int) -> void:
	
	var value = dict[button_index][item_index]
	
	match button_index:
		0:
			DisplayServer.window_set_size(value)
		
		1:
			DisplayServer.window_set_mode(value)
		
		2:
			Engine.max_fps = value


# ==========================================
# VSYNC
# ==========================================

func on_vsync_toggled(enabled:bool) -> void:
	
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
