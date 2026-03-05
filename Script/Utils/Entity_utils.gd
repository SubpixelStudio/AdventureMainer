extends Node
class_name EntitiesUtils

static func _moviment_dir(node:CharacterBody2D, direction:Vector2, speed:float = 1.0):
	var dir: Vector2 = direction.normalized()
	node.velocity = dir * speed
	node.move_and_slide()



static func _block(node:Entities):
	node._block_system()

static func _apply_knock_back(node:CharacterBody2D, direction:Vector2, force:float = 1.0):
	node.velocity = direction * force
