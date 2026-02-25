extends Node
class_name InputHelper

##isso remapea uma ação do mapa de entrada para a tecla "InputEvent"
static func remap(action: String, new_event: InputEvent, index: int) -> bool:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	
	# Verifica se o novo evento já está presente em alguma posição (evita duplicatas)
	for e in events:
		if e.is_match(new_event):
			return false
	
	# Garante que a lista tenha pelo menos index+1 elementos
	while events.size() <= index:
		# Preenche com eventos vazios (ESC) até atingir o tamanho necessário
		var empty_event = InputEventKey.new()
		empty_event.keycode = KEY_NONE
		events.append(empty_event)
	
	# Substitui o evento no índice
	events[index] = new_event
	
	# Atualiza o InputMap: limpa todos e adiciona a nova lista
	InputMap.action_erase_events(action)
	for e in events:
		InputMap.action_add_event(action, e)
	
	return true

##Retorna uma string do evento no índice `index` da ação `action`.
static func get_event_from_action(action: String, index: int = 0) -> String:
	#=================================================
	#obs: NÃO MEXA NISSO SE NÃO SABE OQUE ESTA FAZENDO
	#=================================================
	var events = InputMap.action_get_events(action)
	if events.is_empty() or index < 0 or index >= events.size():
		return ""
	
	var event = events[index]
	var event_class = event.get_class()
	
	match event_class:
		"InputEventKey":
			var key = event.keycode if event.keycode != 0 else event.physical_keycode
			return OS.get_keycode_string(key)
		
		"InputEventMouseButton":
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					return "Botão Esquerdo"
				MOUSE_BUTTON_RIGHT:
					return "Botão Direito"
				MOUSE_BUTTON_MIDDLE:
					return "Botão do Meio"
				MOUSE_BUTTON_WHEEL_UP:
					return "Roda para Cima"
				MOUSE_BUTTON_WHEEL_DOWN:
					return "Roda para Baixo"
				MOUSE_BUTTON_WHEEL_LEFT:
					return "Roda para Esquerda"
				MOUSE_BUTTON_WHEEL_RIGHT:
					return "Roda para Direita"
				_:
					return "Mouse %d" % event.button_index
		
		"InputEventJoypadButton":
			return "Joy %d" % event.button_index
		
		"InputEventJoypadMotion":
			var direction = "+" if event.axis_value > 0 else "-"
			return "Eixo %d %s" % [event.axis, direction]
		
		_:
			# Fallback: limpa prefixos comuns do as_text()
			var text = event.as_text()
			var prefixes = ["Physical ", "Key ", "Button ", "Mouse ", "Joy ", "Axis "]
			for p in prefixes:
				if text.begins_with(p):
					text = text.substr(p.length())
					break
			return text
