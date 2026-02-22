extends CharacterBody2D
class_name Player

const NORMAL_ANIM_SPEED: float = .6
const ATTACK_ANIM_SPEED: float = 1
const HEAVY_MIN_CHARGE := 0.3

@export_group("Properties")
@export var speed: float = 200
@export var attack_cooldown: float = 0.4
@export var damage: int = 10
@export var heavy_damage: int = 30
@export var max_life: int = 100
@export var max_mana: int = 400
@export_group("Nodes")
@export var health: ProgressBar
@export var mana: ProgressBar
@export var npc: Node2D
@export var world: WorldManager
@export var animation: AnimationPlayer
@onready var anim: AnimationPlayer = $Anim
@onready var attack_area: Area2D = $AttackArea
@onready var parry_buffer_timer: Timer = $ParryBufferTimer
@onready var parry_effect: ParryEffect = $ParryEffect


@onready var life: int = max_life
@onready var power: int = max_mana

var last_direction: Vector2 = Vector2.DOWN

var can_attack: bool = true
var is_attacking: bool = false
var attack_index: int = 1
var is_dead: bool = false
var is_attacked: bool = false

var knockback = Vector2.ZERO
var heavy_knockback: float = 800 
var min_knockback := 100.0
var slow_knockback := 1.1

var heavy_cost: int = 50
#var is_charging_heavy: bool = false
var attack_press_time: int = 0
var heavy_attack_time := 0.15
var attack_hold_time: float = 0.0
var is_holding_attack: bool = false

enum PlayerState {
	NONE,
	IDLE,
	WALK,
	ATTACK,
	HOLD_HEAVY_ATTACK,
	RELEASE_HEAVY_ATTACK,
	BLOCK,
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
	switch_state(PlayerState.IDLE)
	
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	update_enemy_list()
	
	parry_effect.z_index = z_index
	parry_effect.call_deferred("reparent", world)

# -------------------------------------------------

func _physics_process(_delta: float) -> void:
	_handle_states()
	calc_knockback()
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
			_pre_attack_state()
		
		PlayerState.HOLD_HEAVY_ATTACK:
			_pre_hold_heavy_attack_state()
			#play_heavy_attack_animation(is_holding_attack)
		
		PlayerState.RELEASE_HEAVY_ATTACK:
			_pre_release_heavy_attack_state()
			#play_heavy_attack_animation(is_holding_attack)
		
		PlayerState.BLOCK:
			parry_buffer_timer.start()

#--------------------------------------------------
func _idle_state() -> void:
	handle_movement()
	
	# Reencher vida e power/mana
	if power < max_mana:
		power += 2
	if not is_attacked:
		if life < max_life:
			life += 1
	
	if velocity != Vector2.ZERO:
		switch_state(PlayerState.WALK)
	
	if power > 0:
		if Input.is_action_pressed("block"):
			switch_state(PlayerState.BLOCK)
		
		if Input.is_action_just_pressed("attack"):
			attack_press_time = Time.get_ticks_msec()
		
		if Input.is_action_just_released("attack"):
			# Verifica quanto tempo ficou com o btn pressionando
			var held_time := (Time.get_ticks_msec() - attack_press_time) / 1000.0
			
			if held_time <= heavy_attack_time:
				# Fluxo pra aplicar Light Attack
				attack()
			else:
				# Fluxo pra aplicar Heavy Attack
				#print('CARGHING')
				#play_heavy_attack_animation(is_holding_attack)
				#print('HEAVY ATTACK')
				#play_heavy_attack_animation(!is_holding_attack)
				hold_heavy_attack()
			#is_holding_attack = false

func _walk_state() -> void:
	handle_movement()
	play_walk_animation()
	
	if velocity == Vector2.ZERO:
		switch_state(PlayerState.IDLE)
	
	if power > 0:
		if Input.is_action_pressed("block"):
			switch_state(PlayerState.BLOCK)
		
		if Input.is_action_just_pressed("attack"):
			attack()

func _pre_attack_state() -> void:
	can_attack = false
	is_attacking = true
	play_attack_sound()
	velocity = Vector2.ZERO
	power -= 20
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


func _pre_hold_heavy_attack_state() -> void:
	is_holding_attack = true
	can_attack = false
	is_attacking = true
	velocity = Vector2.ZERO
	#power -= 40
	while not Input.is_action_just_released("attack"):
		last_direction = get_target_direction()
		play_heavy_attack_animation(is_holding_attack)
		
		attack_area.monitoring = true
		# Acabar ataque. Ainda não dá pra atacar, mas dá pra se mover
		await anim.animation_finished
		attack_area.monitoring = false
		is_attacking = false

	switch_state(last_state)
	# Reativar ataque após cooldown
	await get_tree().create_timer(attack_cooldown*2).timeout
	can_attack = true


func _pre_release_heavy_attack_state() -> void:
	power -= 40
	pass


func _block_state() -> void:
	handle_movement()
	
	if velocity == Vector2.ZERO:
		anim.speed_scale = NORMAL_ANIM_SPEED
		play_directional_animation("blockidle")
	else:
		last_direction = get_target_direction()
		anim.speed_scale = NORMAL_ANIM_SPEED * .6
		play_directional_animation("blockwalk")
	
	# Ficar mais lento
	velocity *= .5
	
	# Diminuir stamina pra não ficar bloqueando pra sempre
	power -= 1
	
	# Parou de bloquear
	if not Input.is_action_pressed("block") or power <= 0:
		if velocity == Vector2.ZERO:
			switch_state(PlayerState.IDLE)
		else:
			switch_state(PlayerState.WALK)
#--------------------------------------------------

func _handle_states() -> void:
	match state:
		PlayerState.IDLE:
			_idle_state()
		PlayerState.WALK:
			_walk_state()
		PlayerState.ATTACK:
			pass #_attack_state()
		PlayerState.BLOCK:
			_block_state()

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

func hold_heavy_attack() -> void:
	switch_state(PlayerState.HOLD_HEAVY_ATTACK)

func release_heavy_attack() -> void:
	switch_state(PlayerState.RELEASE_HEAVY_ATTACK)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		body.knockback = position.direction_to(body.position) * 500

# -------------------------------------------------
# VIDA / MORTE
# -------------------------------------------------

func take_damage(amount: int, attacker: CharacterBody2D = null) -> void:
	if is_dead:
		return
	var attacker_dir: Vector2
	if attacker:
		attacker_dir = attacker.position.direction_to(position)
	
	if state == PlayerState.BLOCK:
		knockback = attacker_dir * 150
		# Espaço de tempo que é possivel dar parry
		if parry_buffer_timer.time_left > 0:
			play_parry_sound()
			
			# Matar o inimigo que tomou parry
			if attacker and attacker.has_method("take_damage"):
				attacker.take_damage(attacker.life)
			parry_buffer_timer.stop()
			knockback = attacker_dir * 500
			
			parry_effect.global_position = global_position
			parry_effect.start_parry()
			
			print("PARRY!!!")
		return
	
	is_attacked = true
	life -= amount
	
	knockback = attacker_dir * 350
	
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

func play_heavy_attack_animation(is_holding: bool) -> void:
	anim.speed_scale = ATTACK_ANIM_SPEED
	var action = '_hold' if is_holding else '_release'
	if action == '_hold':
		print('ANIMACAO ' + action + ' TOCANDO')
	play_directional_animation("heavy_attack" + action)
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

func calc_knockback() -> void:
	if knockback.length() > min_knockback:
		knockback /= slow_knockback
		velocity = knockback
		move_and_slide()
		return

func play_attack_sound():
	var sound := SoundManager.new()
	sound.stream = preload("res://Assets/Sound/swordslash1.mp3")
	add_child(sound)
	sound.play()
func play_parry_sound():
	var sound := SoundManager.new()
	sound.stream = preload("res://Assets/Sound/swordparry1.mp3")
	add_child(sound)
	sound.play()
