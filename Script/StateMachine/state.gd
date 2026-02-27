extends Node

class_name State

var actor: Node
var manager: StateManager

func _start() -> void: pass
func _run(delta: float) -> void: pass
func _end() -> void: pass
