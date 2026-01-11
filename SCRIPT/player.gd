extends CharacterBody2D

@export var speed: float = 200
@export var attack_cooldown: float = 0.4
@export var damage: int = 10
@export var max_life: int = 100
@export var max_mana:int = 200
@export var anim: AnimationPlayer
@export var attack_area: Area2D
@export var health:ProgressBar
@export var mana:ProgressBar
@export var npc:Node2D
@export var world:WorldManager
@export var animation:AnimationPlayer
var life: int
var power: int
var last_direction: Vector2 = Vector2.DOWN

var can_attack := true
var is_attacking := false
var attack_index := 1
var is_dead := false
var is_attacked := false

# ------------------------------
# SISTEMA DE ALVO
# ------------------------------
var enemies: Array[Node2D] = []
var target_index := 0
var current_target: Node2D = null

# -------------------------------------------------

func _ready():
	life = max_life
	power = max_mana
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)

	update_enemy_list()

# -------------------------------------------------

func _physics_process(delta):
	health.value = life
	health.max_value = max_life
	mana.value = power
	mana.max_value = max_mana
	if is_dead:
		return

	update_enemy_list()
	handle_target_selection()
	update_attack_area()

	if is_attacking:
		velocity = Vector2.ZERO
	else:
		handle_movement()
		handle_attack_input()

	move_and_slide()

# -------------------------------------------------
# INIMIGOS / ALVO
# -------------------------------------------------

func update_enemy_list():
	enemies.clear()

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D:
			enemies.append(enemy)

	if enemies.is_empty():
		current_target = null
		return

	target_index = clamp(target_index, 0, enemies.size() - 1)
	current_target = enemies[target_index]


func handle_target_selection():
	if Input.is_action_just_pressed("enemy"):
		if enemies.is_empty():
			current_target = null
			return

		for i in range(1, enemies.size() + 1):
			var next_index = (target_index + i) % enemies.size()
			if enemies[next_index]:
				target_index = next_index
				current_target = enemies[target_index]
				break



func get_target_direction() -> Vector2:
	if current_target:
		return (current_target.global_position - global_position).normalized()
	return last_direction
# -------------------------------------------------
# ATUALIZAÇÃO DO HITBOX (MIRA)
# -------------------------------------------------

func update_attack_area():
	var shape := attack_area.get_node("Polygon")
	var direction := get_target_direction()

	# ajuste para shape que aponta para cima
	shape.rotation = direction.angle() - PI / 2
	shape.disabled = not is_attacking

# -------------------------------------------------
# MOVIMENTO
# -------------------------------------------------

func handle_movement():
	var input_vector := Input.get_vector("A", "D", "W", "S")
	velocity = input_vector * speed

	if input_vector != Vector2.ZERO:
		last_direction = input_vector.normalized()
		play_walk_animation()
	else:
		play_idle_animation()

# -------------------------------------------------
# ATAQUE
# -------------------------------------------------

func handle_attack_input():
	if Input.is_action_pressed("attack") and can_attack and power > 0:
		attack()
		power -= 10

func attack():
	can_attack = false
	is_attacking = true

	# trava a direção do ataque
	last_direction = get_target_direction()

	play_attack_animation()

	attack_area.monitoring = true
	await anim.animation_finished

	attack_area.monitoring = false
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _on_attack_area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

# -------------------------------------------------
# VIDA / MORTE
# -------------------------------------------------

func take_damage(amount: int):
	if is_dead:
		return

	is_attacked = true
	life -= amount

	if life <= 0:
		die()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	print("Player morreu")

	await get_tree().create_timer(0.3).timeout
	get_tree().reload_current_scene()

# -------------------------------------------------
# ANIMAÇÕES
# -------------------------------------------------

func play_walk_animation():
	play_directional_animation("walk")
	animation.play('Walking')

func play_idle_animation():
	play_directional_animation("idle")
	animation.play('Current')
	if power < max_mana and !is_attacked:
		power += 1
	if life < max_life and !is_attacked:
		life += 1

func play_attack_animation():
	animation.play('Current')
	play_directional_animation("attack", true)

func play_directional_animation(prefix: String, alternate := false):
	var anim_name := ""

	if abs(last_direction.x) > abs(last_direction.y):
		anim_name = prefix + ("_right" if last_direction.x > 0 else "_left")
	else:
		anim_name = prefix + ("_down" if last_direction.y > 0 else "_up")

	if alternate:
		anim_name += str(attack_index)
		attack_index = 2 if attack_index == 1 else 1

	if anim.current_animation != anim_name:
		anim.play(anim_name)
