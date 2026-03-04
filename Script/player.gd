extends CharacterBody2D
class_name Player

const NORMAL_ANIM_SPEED: float = .6
const ATTACK_ANIM_SPEED: float = 1

@export_group("Properties")
@export var speed: float = 200
@export var attack_cooldown: float = 0.4
@export var damage: int 
@export var max_life: int = 100
@export var max_mana: int = 400
@export_group("Nodes")
@export var health: ProgressBar
@export var mana: ProgressBar
@export var npc: Node2D
@export var world: WorldManager
@export var animation: AnimationPlayer
@export var soundManager:Node
@onready var anim: AnimationPlayer = $Anim
@onready var attack_area: Area2D = $AttackArea
@onready var parry_buffer_timer: Timer = $ParryBufferTimer
@onready var parry_effect: ParryEffect = $ParryEffect

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")

@onready var life: int = max_life
@onready var power: int = max_mana

var input_vector: Vector2 = Vector2.DOWN
var last_direction: Vector2 = Vector2.DOWN
var mira: Sprite2D = null

var can_attack: bool = true
var is_attacking: bool = false
var attack_index: int = 1
var is_dead: bool = false
var is_attacked: bool = false

var knockback = Vector2.ZERO
var min_knockback := 100.0
var slow_knockback := 1.1

enum PlayerState {
	NONE,
	IDLE,
	WALK,
	ATTACK,
	BLOCK,
}

var step_interval = 0.35
var step_timer = Timer.new()
var state: PlayerState
var last_state: PlayerState

# ------------------------------
# SISTEMA DE ALVO
# ------------------------------
var enemies: Array[Node2D] = []
var target_index: int = 0
var current_target: Node2D = null


# ------------------------------
# SISTEMA DE INTERAÇÃO
# ------------------------------
## a area de interação do player
@onready var area_interact:Area2D =  $Area2D
##isso deve rodar toda vez e achar o npc mais perto(ainda sem utilidade)
##não adicionei nada ao codigo para não processar sobrecarregar de funções
var npc_interact_tartget:Generic_NPC
## sinal emite o npc que interagiu
signal interacted_npc(npc:Generic_NPC)


# -------------------------------------------------

func _ready() -> void:
	# Liga animation tree no idle
	anim_tree.active = true
	#state_machine.travel("Idle")
	
	#switch_state(PlayerState.IDLE)
	#step_timer.wait_time = step_interval
	#step_timer.timeout.connect(play_walking_sound)
	#add_child(step_timer)
	#attack_area.monitoring = false
	#attack_area.body_entered.connect(_on_attack_area_body_entered)
	#update_enemy_list()
	#
	#parry_effect.z_index = z_index
	#parry_effect.call_deferred("reparent", world)

# -------------------------------------------------

func _physics_process(_delta: float) -> void:
	input_vector = Input.get_vector("A", "D", "W", "S").normalized()
	
	if input_vector != Vector2.ZERO:
		#state_machine.travel("run")
		anim_tree.set("parameters/Run/blend_position", input_vector)
	else:
		#state_machine.travel("idle")
		anim_tree.set("parameters/Idle/blend_position", last_direction)
	
	
	if is_dead:
		return
	_handle_states()
	calc_knockback()
	health.value = life
	health.max_value = max_life
	mana.value = power
	mana.max_value = max_mana
	update_enemy_list()
	handle_target_selection()
	update_attack_area()
	interact_update()
	
	move_and_slide()

func interact_update():
	
	if not area_interact: return
	if Input.is_action_just_pressed("interagir"):
		var bodies = area_interact.get_overlapping_bodies()
		var near_npc:Generic_NPC
		var shortest_distance = INF
		for body in bodies:
			if body is Generic_NPC:
				# Calcula a distância entre seu personagem e o NPC
				var distance = global_position.distance_to(body.global_position)
				
				# Verifica se é o NPC mais próximo encontrado até agora
				if distance < shortest_distance:
					shortest_distance = distance
					near_npc = body
		if near_npc:
			##aqui é o npc mais perto
			interacted_npc.emit(near_npc)
		else:
			##aqui é quando não acha nenhum npc
			pass
			print("nenhum npc achado")

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
	#print("Player State: %s" % PlayerState.find_key(state))
	
	match new_state:
		PlayerState.IDLE:
			play_idle_animation()
		
		PlayerState.WALK:
			play_walk_animation()
		
		PlayerState.ATTACK:
			_attack_state(_pre_attack_state())
		
		PlayerState.BLOCK:
			parry_buffer_timer.start()

#--------------------------------------------------
func _idle_state() -> void:
	handle_movement()
	if power < max_mana:
		power += 1
	if not is_attacked:
		if life < max_life:
			life += 1
	
	if velocity != Vector2.ZERO:
		switch_state(PlayerState.WALK)
	
	if power > 0:
		if Input.is_action_pressed("block"):
			switch_state(PlayerState.BLOCK)
		if Input.is_action_just_pressed("attack") or Input.is_action_pressed("attack"):
			attack()
			

func carregando_attack(charge_time: float) -> int:
	# Configurações locais
	var base_damage: int = 20
	var stamina_cost: int = 10
	var max_charge_time: float = 2.0
	var max_stamina_multiplier: float = 2.0
	if power < stamina_cost:
		return 0
	# Normaliza stamina (0 → 1)
	var stamina_ratio: float = clamp(float(power) / float(max_mana), 0.0, 1.0)
	# Normaliza charge (0 → 1)
	charge_time = clamp(charge_time, 0.0, max_charge_time)
	var charge_ratio: float = charge_time / max_charge_time
	# Consome stamina
	power -= stamina_cost
	# Dano base escalado pela stamina + carga
	var final_damage: float = base_damage
	final_damage *= lerp(1.0, max_stamina_multiplier, stamina_ratio)
	final_damage *= lerp(1.0, 1.5, charge_ratio)
	return int(final_damage)




func _walk_state() -> void:
	handle_movement()
	play_walk_animation()
	if velocity == Vector2.ZERO:
		step_timer.stop()
		switch_state(PlayerState.IDLE)
		return

	if step_timer.is_stopped():
		step_timer.start()

	if power > 0:
		if Input.is_action_pressed("block"):
			switch_state(PlayerState.BLOCK)
		if Input.is_action_just_pressed("attack") or Input.is_action_pressed("attack"):
			attack()

func _pre_attack_state() -> int:
	var final_damage = carregando_attack(2.0)
	return final_damage
func _attack_state(amount) -> void:
	#print(damage)
	can_attack = false
	is_attacking = true
	play_attack_sound()
	velocity = Vector2.ZERO
	damage = amount 
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
		if mira and mira.get_parent():
			mira.get_parent().remove_child(mira)
		return

	target_index = clamp(target_index, 0, enemies.size() - 1)

	# Define alvo inicial
	if current_target == null:
		current_target = enemies[target_index]

		if mira == null:
			mira = preload("res://Cenas/mira.tscn").instantiate()

		current_target.add_child(mira)
		mira.position = Vector2(0, -5)



func handle_target_selection() -> void:
	if not Input.is_action_just_pressed("enemy"):
		return

	if enemies.is_empty():
		current_target = null
		if mira and mira.get_parent():
			mira.get_parent().remove_child(mira)
		return

	for i in range(1, enemies.size() + 1):
		var next_index := (target_index + i) % enemies.size()
		var next_enemy := enemies[next_index]

		if not is_instance_valid(next_enemy):
			continue

		target_index = next_index
		current_target = next_enemy

		if mira == null:
			mira = preload("res://Cenas/mira.tscn").instantiate()

		# Remove do alvo antigo
		if mira.get_parent():
			mira.get_parent().remove_child(mira)

		current_target.add_child(mira)
		mira.position = Vector2(0, -10)
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
	pass
	#var input_vector: Vector2 = Input.get_vector("A", "D", "W", "S").normalized()
	#velocity = input_vector * speed
	#
	#if input_vector != Vector2.ZERO:
		#last_direction = input_vector.normalized()

# -------------------------------------------------
# ATAQUE
# -------------------------------------------------

func attack() -> void:
	switch_state(PlayerState.ATTACK)


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
		if parry_buffer_timer.time_left > 0 and attacker:
			parry_buffer_timer.stop()
			knockback = attacker_dir * 500
			
			# Ele tem q ficar morto, senao não da pra mudar a anim dele, pq o play_directional sobrescreve
			attacker.is_dead = true
			attacker.anim.play("dead_down")
			
			await attacker.anim.current_animation_changed
			
			parry_effect.global_position = global_position
			parry_effect.start_parry()
			if parry_effect.has_method("start_parry"):
				play_parry_sound()
			# Matar o inimigo que tomou parry, depois do jogo destravar/despausar
			await parry_effect.unfrozen
			
			attacker.is_dead = false
			attacker.die()
		return
	
	is_attacked = true
	life -= amount
	
	knockback = attacker_dir * 350
	
	if life <= 0:
		if GameData.jogador_imortal:	return
		die()

func die() -> void:
	GameData.has_died = true
	is_dead = true
	velocity = Vector2.ZERO
	print("Player morreu")
	
	await get_tree().create_timer(0.3).timeout
	get_tree().reload_current_scene()


# -------------------------------------------------
# ANIMAÇÕES
# -------------------------------------------------

func play_idle_animation() -> void:
	pass
	#anim.speed_scale = NORMAL_ANIM_SPEED
	#play_directional_animation("idle")
	#animation.play("Current")

func play_walk_animation() -> void:
	pass
	#anim.speed_scale = NORMAL_ANIM_SPEED
	#play_directional_animation("walk")
	#animation.play("Walking")


func play_attack_animation() -> void:
	pass
	#anim.speed_scale = ATTACK_ANIM_SPEED
	#play_directional_animation("attack", true)
	#animation.play("Current")

func play_directional_animation(prefix: String, alternate: bool = false) -> void:
	pass
	#var sufix: String
	#
	#if abs(last_direction.x) > abs(last_direction.y):
		#sufix = ("_right" if last_direction.x > 0 else "_left")
	#else:
		#sufix = ("_down" if last_direction.y > 0 else "_up")
	#var anim_name: String = prefix + sufix
	#
	#if alternate:
		#anim_name += str(attack_index)
		#attack_index = 2 if attack_index == 1 else 1
#
	#if anim.current_animation != anim_name:
		#anim.play(anim_name)


# -------------------------------------------------
# KNOCKBACK / SOM
# -------------------------------------------------

func calc_knockback() -> void:
	if knockback.length() > min_knockback:
		knockback /= slow_knockback
		velocity = knockback
		return

func play_walking_sound() -> void:
	const WALKING_SOUND:AudioStream = preload("res://Assets/Sound/Step.mp3")
	SoundEffect.play_sound(WALKING_SOUND,soundManager,global_position)
func play_attack_sound() -> void:
	const ATTACK_SOUND: AudioStream = preload("res://Assets/Sound/swordslash1.mp3")
	SoundEffect.play_sound(ATTACK_SOUND,soundManager, global_position)

func play_parry_sound() -> void:
	const PARRY_SOUND: AudioStream = preload("res://Assets/Sound/swordparry1.mp3")
	SoundEffect.play_sound(PARRY_SOUND,soundManager, global_position)

func _unhandled_input(_event: InputEvent) -> void:
	input_vector = Input.get_vector("A", "D", "W", "S").normalized()
	print(input_vector)


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Tree"):
		if area.has_method("take_damage"):
			area.take_damage(1)
