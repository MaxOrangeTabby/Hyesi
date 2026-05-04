extends CharacterBody2D

#@export var inventory_system : Inventory
@export var player_actions : PlayerActions
@export var player_stats : PlayerStats

@onready var hsm : LimboHSM = %LimboHSM
@onready var coyote_timer : Timer = %CoyoteTimer
@onready var jump_buffer_timer : Timer = %JumpBufferTimer
@onready var hit_stun_timer : Timer = %HitStunTimer
@onready var regen_tick_timer : Timer = %RegenTickTimer
@onready var regen_delay_timer : Timer = %RegenDelayTimer

@onready var anim_player : AnimationPlayer = %AnimPlayer

@onready var sprite : Sprite2D = %MainSprite
@onready var flip_root : Node2D = %FlipRoot
var blackboard : Blackboard = null

@export var curr_sprite_scale : float = .3

@export_group("move")
@export var speed : float
@export var friction : float
@export var acceleration : float
@export var gravity : float 
@export var term_vel : float
@export var jump_strength : float

var jump : bool = false
var wall_jump : bool = false
var faster_fall : bool = false
var can_move : bool = true
var input_enabled : bool = true

var push_force : float = 90.0
var is_dying : bool = false

@export_group("attack")
@export var max_hp : float
@export var current_hp : float
@export var knockback_str : float = 2750

@export_group("regen")
@export var regen_rate : float = .005

const COLLIDE_ENEMY_LAYER : int = 8
const floating_label : PackedScene = preload("uid://bfxferv8gi6c5")
const death_anim_name : StringName = "die"
const revive_anim_name : StringName = "revive"

var seen_timelines : Dictionary = {}


func _ready() -> void:
	max_hp = PlayerKit.hp
	current_hp = max_hp
	
	reset_combat_state()
	hsm.initialize(self)
	hsm.set_active(true)
	
	blackboard = hsm.blackboard
	
	# setup player stats
	speed = player_stats.player_velocity
	friction = player_stats.player_friction
	acceleration = player_stats.player_acceleration
	gravity = player_stats.player_gravity
	term_vel = player_stats.player_term_vel
	jump_strength = player_stats.player_jump_strength
	
	SignalBus.stats_updated.connect(recalc_stats)
	SignalBus.player_heal.connect(heal_player)

func _process(delta: float) -> void:
	apply_grav(delta)

func apply_grav(delta : float) -> void: 
	velocity.y += gravity * delta
	velocity.y = (3 * velocity.y)/4 if faster_fall and velocity.y < 0 else velocity.y
	velocity.y = min(velocity.y, term_vel)
	
func face_dir(dir : float) -> void:
	if dir > 0.0:
		flip_root.scale.x = 1.0
	elif dir < 0.0:
		flip_root.scale.x = -1.0

func activateSpring(springStrength : Vector2) -> void: 
	velocity.x += springStrength.x
	velocity.y = springStrength.y


func disable_input():
	blackboard.set_var(BBNames.can_move_var, false)

func enable_input():
	blackboard.set_var(BBNames.can_move_var, true)

# timer played shortly after logn press cel spike
func _on_spike_float_timer_timeout() -> void:
	var grav_tween : Tween = create_tween()
	grav_tween.set_ease(Tween.EASE_IN)
	grav_tween.set_trans(Tween.TRANS_SINE)
	grav_tween.tween_property(self, "gravity", player_stats.player_gravity, .45)
	#gravity = player_stats.player_gravity

# IF ANY STATES CHANGE STATES -> CALL THIS ON EXIT
func recalc_stats() -> void: 
	#print("player gd: player kit move spd: ", PlayerKit.move_speed)
	speed = player_stats.player_velocity * PlayerKit.move_speed
	friction = player_stats.player_friction * PlayerKit.move_speed
	acceleration = player_stats.player_acceleration * PlayerKit.move_speed
	gravity = player_stats.player_gravity
	term_vel = player_stats.player_term_vel
	jump_strength = player_stats.player_jump_strength
	
	var new_max_hp : float = PlayerKit.hp
	if new_max_hp > max_hp:
		current_hp += (new_max_hp - max_hp)
	max_hp = new_max_hp
	current_hp = min(current_hp, max_hp)
	SignalBus.player_hp_changed.emit(current_hp, max_hp)

func reset_combat_state() -> void:
	set_collision_mask_value(COLLIDE_ENEMY_LAYER, true)

func take_damage(amount : float, _enemy, source_pos : Vector2 = Vector2.INF, kb_power : float = 50) -> void:
	#print("PLAYER TAKE DMG")
	if not is_instance_valid(_enemy):
		_enemy = null
	
	PlayerKit.on_damaged.emit({
		"damage_taken" : amount,
		"enemy" : _enemy
	})
	
	current_hp -= amount
	regen_delay_timer.start()
	regen_tick_timer.stop()
	SignalBus.player_hp_changed.emit(current_hp, max_hp)
	SignalBus.player_damaged.emit()
	
	if source_pos != Vector2.INF:
		var kb_dir : Vector2 =  global_position - source_pos
		if kb_dir.length_squared() > .0001:
			velocity = kb_dir.normalized() * kb_power
			#print("PLAYER KNOCKED BACK")
		blackboard.set_var(BBNames.can_move_var, false)
		hit_stun_timer.start()
	
	if current_hp <= 0 and not is_dying:
		is_dying =true
		die()

func heal_player(heal_amount : float) -> void:
	current_hp = min(current_hp + heal_amount, max_hp)
	SignalBus.player_hp_changed.emit(current_hp, max_hp)


func _on_hit_stun_timer_timeout() -> void:
	blackboard.set_var(BBNames.can_move_var, true)

func show_floating_label(_text : String) -> void: 
	var label_inst = floating_label.instantiate()
	add_child(label_inst)
	label_inst.position.y -= 10
	label_inst.text = _text


func _on_regen_tick_timer_timeout() -> void:
	if current_hp >= max_hp:
		regen_tick_timer.stop()
		return
	
	var heal_amt : float = max_hp * regen_rate
	current_hp = min(current_hp + heal_amt, max_hp)
	SignalBus.player_hp_changed.emit(current_hp, max_hp)


func _on_regen_delay_timer_timeout() -> void:
	if current_hp < max_hp:
		regen_tick_timer.start()

func die() -> void:
	
	if hsm:
		hsm.set_active(false)
	velocity = Vector2.ZERO
	set_process(false)
	
	anim_player.play(death_anim_name)
	await anim_player.animation_finished
	SignalBus.player_die.emit()

	var respawn_pos : Vector2
	if GameManager.in_boss_fight:
		respawn_pos = GameManager.current_arena_start
	else:
		respawn_pos = CheckpointManager.get_respawn_pos()
	
	global_position = respawn_pos
	velocity = Vector2.ZERO
	current_hp = max_hp
	regen_delay_timer.stop()
	regen_tick_timer.stop()
	
	await get_tree().create_timer(1.15).timeout
	anim_player.play(revive_anim_name)
	await anim_player.animation_finished

	SignalBus.player_hp_changed.emit(current_hp, max_hp)
	blackboard.set_var(BBNames.can_move_var, true)
	
	set_process(true)
	if hsm:
		hsm.set_active(true)
	is_dying = false

func start_dialogue(_timeline : String) -> void:
	if seen_timelines.has(_timeline):
		return
	seen_timelines[_timeline] = true
	Dialogic.start(_timeline)
	blackboard.set_var(BBNames.can_move_var, false)
	await Dialogic.timeline_ended
	blackboard.set_var(BBNames.can_move_var, true)
