extends CharacterBody2D

signal died
@export var speed: float = 120
@export var attack_range: float = 40
@export var attack_cooldown: float = 1.0
@export var array_damage: Array[int]
@export var choices_life : Array[int]
@export var anim: AnimationPlayer

var knockback = Vector2.ZERO
var min_knockback := 100.0
var slow_knockback := 1.1

var player: CharacterBody2D
var life: int
var last_direction: Vector2 = Vector2.DOWN

var can_attack: bool = true
var is_attacking: bool = false
var attack_index: int = 1
var is_dead: bool = false

# -------------------------------------------------

func _ready():
	life = choices_life[randi() % choices_life.size()]
	player = get_tree().get_first_node_in_group("Player")

# -------------------------------------------------

func _physics_process(_delta):
	calc_knockback()
	if player == null or is_dead:
		return

	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()

	if is_attacking:
		velocity = Vector2.ZERO
	elif distance > attack_range:
		chase_player(to_player)
	else:
		velocity = Vector2.ZERO
		play_idle_animation()

		if can_attack:
			attack()

	move_and_slide()

# -------------------------------------------------
# IA
# -------------------------------------------------

func chase_player(direction: Vector2):
	var dir: Vector2 = direction.normalized()
	last_direction = dir
	velocity = dir * speed
	play_walk_animation()

# -------------------------------------------------
# ATAQUE
# -------------------------------------------------

func attack():
	can_attack = false
	is_attacking = true
	
	play_attack_animation()
	
	player.take_damage(array_damage[randi() % array_damage.size()], self)
	
	await anim.animation_finished
	is_attacking = false
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

# -------------------------------------------------
# VIDA / DANO / MORTE
# -------------------------------------------------

func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	life -= amount
	#print("Inimigo vida:", life)

	
	if life <= 0:
		die()

func die():
	# Previnir que morra denovo
	if is_dead:
		return
	
	player.is_attacked = false
	is_dead = true
	velocity = Vector2.ZERO
	#print("Inimigo morreu")
	died.emit()
	await get_tree().create_timer(0.1).timeout
	queue_free()

# -------------------------------------------------
# ANIMAÇÕES
# -------------------------------------------------

func play_walk_animation():
	play_directional_animation("walk")

func play_idle_animation():
	play_directional_animation("idle")

func play_attack_animation():
	play_directional_animation("attack", true)

func play_directional_animation(prefix: String, alternate: bool = false):
	var sufix: String
	
	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			sufix = "_right"
		else:
			sufix = "_left"
	else:
		if last_direction.y > 0:
			sufix = "_down"
		else:
			sufix = "_up"
	var anim_name: String = prefix + sufix
	
	if alternate:
		anim_name += str(attack_index)
		toggle_attack_index()
	
	play_if_not(anim_name)

func toggle_attack_index():
	if attack_index == 1:
		attack_index = 2
	else:
		attack_index = 1

func play_if_not(anim_name: String):
	if anim.current_animation != anim_name:
		anim.play(anim_name)

func calc_knockback() -> void:
	if knockback.length() > min_knockback:
		knockback /= slow_knockback
		velocity = knockback
		move_and_slide()
		return
