extends Node
class_name EntitiesUtils

static func _moviment_dir(node:CharacterBody2D, direction:Vector2, speed:float = 1.0):
	var dir: Vector2 = direction.normalized()
	node.velocity = dir * speed
	node.move_and_slide()

static func _area_attack(area2D:Area2D, damage:int = 0):
	var Nodes:Array[Node2D] =area2D.get_overlapping_bodies()
	for i in Nodes:
		if i is Entities:
			i._received_damage(damage)

static func _block(node:Entities):
	node._block_system()

static func _apply_knock_back(node:CharacterBody2D, direction:Vector2, force:float = 1.0):
	node.velocity = direction * force
