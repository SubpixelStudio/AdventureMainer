extends Area2D

@onready var chopped_shape: CollisionShape2D = $ChoppedShape
@onready var normal_shape: CollisionShape2D = $NormalShape
@onready var texture: AnimatedSprite2D = $Texture

@export var health: int = 3

var is_chopped := false

func _ready() -> void:
	chopped_shape.disabled = true
	normal_shape.disabled = false
	#texture.play("Normal")

func _physics_process(delta: float) -> void:
	if is_chopped:
		texture.play("Chopped")
		$"../Shape".shape = chopped_shape.shape
		$"../Shape".position = Vector2(234,429)
	else:
		texture.play("Normal")
		$"../Shape".shape = normal_shape.shape
		$"../Shape".position = Vector2(241,396)
func take_damage(amount: int) -> void:
	if is_chopped:
		return
	
	health -= amount
	
	if health <= 0:
		chop()

func chop() -> void:
	is_chopped = true
	$Timer.start()
	normal_shape.disabled = true
	chopped_shape.disabled = false
	#texture.play("Chopped")

func _on_timer_timeout() -> void:
	health = 3
	is_chopped = false
	normal_shape.disabled = false
	chopped_shape.disabled = true
