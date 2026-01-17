extends CharacterBody2D
class_name Player

const NORMAL_ANIM_SPEED: float = .6
const ATTACK_ANIM_SPEED: float = 1

@export_group("Properties")
@export var speed: float = 200
@export var attack_cooldown: float = 0.4
@export var damage: int = 10
@export var max_life: int = 100
@export var max_mana: int = 200
@export_group("Nodes")
@export var health: ProgressBar
@export var mana: ProgressBar
@export var npc: Node2D
@export var world: WorldManager
@export var animation: AnimationPlayer

@onready var anim: AnimationPlayer = $Anim
@onready var attack_area: Area2D = $AttackArea

@onready var life: int = max_life
@onready var power: int = max_mana

var last_direction: Vector2 = Vector2.DOWN

var can_attack: bool = true
var is_attacking: bool = false
var attack_index: int = 1
var is_dead: bool = false
var is_attacked: bool = false

enum PlayerState {
	NONE,
	IDLE,
	WALK,
	ATTACK
}

var state: PlayerState
var last_state: PlayerState

# ------------------------------
# SISTEMA DE ALVO
# ------------------------------
var enemies: Array[Node2D] = []
var target_index: int = 0
var current_target: Node2D = null

# -------------------------------------------------

func _ready() -> void:
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	switch_state(PlayerState.IDLE)
	last_state = PlayerState.IDLE
	update_enemy_list()

# -------------------------------------------------

func _physics_process(_delta: float) -> void:
	_handle_states()
	
	health.value = life
	health.max_value = max_life
	mana.value = power
	mana.max_value = max_mana
	if is_dead:
		return
	
	update_enemy_list()
	handle_target_selection()
	update_attack_area()
	
	move_and_slide()

#--------------------------------------------------
# STATE MACHINE
#--------------------------------------------------

func switch_state(new_state: PlayerState) -> void:
	# Previnir que troque pro mesmo estado
	if state == new_state: 
		print("Player: Can't switch to current state")
		return
	last_state = state
	state = new_state
	print("Player State: %s" % PlayerState.find_key(state))
	
	match new_state:
		PlayerState.IDLE:
			play_idle_animation()
		
		PlayerState.WALK:
			play_walk_animation()
		
		PlayerState.ATTACK:
			can_attack = false
			is_attacking = true
			
			velocity = Vector2.ZERO
			power -= 10
			# Olhar pro inimigo pra atacá-lo
			last_direction = get_target_direction()
			play_attack_animation()
			
			attack_area.monitoring = true
			
			# Acabar ataque. Ainda não dá pra atacar, mas dá pra se mover
			await anim.animation_finished
			
			attack_area.monitoring = false
			is_attacking = false
			
			switch_state(last_state)
			
			# Reativar ataque após cooldown
			await get_tree().create_timer(attack_cooldown).timeout
			can_attack = true

#--------------------------------------------------
func _idle_state() -> void:
	handle_movement()
	
	# Reencher vida e power/mana
	if not is_attacked:
		if life < max_life:
			life += 1
		if power < max_mana:
			power += 1
	
	# Mudar estados
	if velocity != Vector2.ZERO:
		switch_state(PlayerState.WALK)
	
	if Input.is_action_just_pressed("attack") and power > 0:
		attack()

func _walk_state() -> void:
	handle_movement()
	play_walk_animation()
	
	if velocity == Vector2.ZERO:
		switch_state(PlayerState.IDLE)
	
	if Input.is_action_just_pressed("attack") and power > 0:
		attack()

func _attack_state() -> void:
	pass
#--------------------------------------------------

func _handle_states() -> void:
	match state:
		PlayerState.IDLE:
			_idle_state()
		PlayerState.WALK:
			_walk_state()
		PlayerState.ATTACK:
			_attack_state()

# -------------------------------------------------
# INIMIGOS / ALVO
# -------------------------------------------------

func update_enemy_list() -> void:
	enemies.clear()
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D:
			enemies.append(enemy)
	
	if enemies.is_empty():
		current_target = null
		return
	
	target_index = clamp(target_index, 0, enemies.size() - 1)
	current_target = enemies[target_index]


func handle_target_selection() -> void:
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

func update_attack_area() -> void:
	var shape := attack_area.get_node("Polygon")
	var direction := get_target_direction()
	
	# ajuste para shape que aponta para cima
	shape.rotation = direction.angle() - PI / 2
	shape.disabled = not is_attacking

# -------------------------------------------------
# MOVIMENTO
# -------------------------------------------------

func handle_movement() -> void:
	var input_vector: Vector2 = Input.get_vector("A", "D", "W", "S")
	velocity = input_vector * speed
	
	if input_vector != Vector2.ZERO:
		last_direction = input_vector.normalized()

# -------------------------------------------------
# ATAQUE
# -------------------------------------------------

func attack() -> void:
	switch_state(PlayerState.ATTACK)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, self)

# -------------------------------------------------
# VIDA / MORTE
# -------------------------------------------------

func take_damage(amount: int, attacker: CharacterBody2D) -> void:

	if is_dead:
		return
	
	is_attacked = true
	life -= amount

	calc_knockback(self, attacker)
	
	if life <= 0:
		if GameData.jogador_imortal:	return
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	print("Player morreu")
	
	await get_tree().create_timer(0.3).timeout
	get_tree().reload_current_scene()


# -------------------------------------------------
# ANIMAÇÕES
# -------------------------------------------------

func play_idle_animation() -> void:
	anim.speed_scale = NORMAL_ANIM_SPEED
	play_directional_animation("idle")
	animation.play("Current")

func play_walk_animation() -> void:
	anim.speed_scale = NORMAL_ANIM_SPEED
	play_directional_animation("walk")
	animation.play("Walking")

func play_attack_animation() -> void:
	anim.speed_scale = ATTACK_ANIM_SPEED
	play_directional_animation("attack", true)
	animation.play("Current")

func play_directional_animation(prefix: String, alternate: bool = false) -> void:
	var sufix: String
	
	if abs(last_direction.x) > abs(last_direction.y):
		sufix = ("_right" if last_direction.x > 0 else "_left")
	else:
		sufix = ("_down" if last_direction.y > 0 else "_up")
	var anim_name: String = prefix + sufix
	
	if alternate:
		anim_name += str(attack_index)
		attack_index = 2 if attack_index == 1 else 1

	if anim.current_animation != anim_name:
		anim.play(anim_name)


static func calc_knockback(me: CharacterBody2D, enemy: CharacterBody2D, forca_do_knockback: int = 2000) -> void:
	var temp = me.velocity
	me.velocity = (me.position - enemy.position).normalized() * forca_do_knockback
	me.move_and_slide()
	me.velocity = temp
