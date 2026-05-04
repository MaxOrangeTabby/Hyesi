class_name PlayerInput
extends Node

@export var agent : CharacterBody2D
@export var player_actions : PlayerActions
@export var limbo_hsm : LimboHSM
@export var cel_spike_state : LimboState
@export var sword_state : LimboState
@export var aim_state : LimboState

@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer
@export var aim_press_timer : Timer
@export var attack_buffer_timer : Timer

@export var cel_spike_detector : Area2D

const dropped_item : PackedScene = preload("uid://ck1m7pdonnj1c")
const item_card : PackedScene = preload("uid://biqh2wxom4kp1")

var aim_released : bool = true

var blackboard : Blackboard
var input_direction : Vector2 = Vector2.ZERO
var jump : bool = false
var faster_fall : bool = false
var attack_pressed : bool = false
var focus_sprite : Sprite2D
var is_dashing : bool = false
var is_sword : bool = false

func _ready() -> void: 
	blackboard = limbo_hsm.blackboard
	blackboard.bind_var_to_property(BBNames.direction_var, self, "input_direction", true)
	blackboard.bind_var_to_property(BBNames.jump_var, self, "jump", true)
	blackboard.bind_var_to_property(BBNames.faster_fall_var, self, "faster_fall", true)
	blackboard.bind_var_to_property(BBNames.is_dashing, self, "is_dashing", true)

func _process(_delta: float) -> void:
	if blackboard.get_var(BBNames.can_move_var) == false:
		return

	input_direction = Input.get_vector(player_actions.move_left, player_actions.move_right, player_actions.move_down, player_actions.move_up)
	if not is_zero_approx(input_direction.x):
		blackboard.set_var(BBNames.x_direction_var, input_direction.x)
		agent.face_dir(input_direction.x)
		

	## DOES NOT USE THIS JUMP LOGIC ON THE WALL STATE
	if Input.is_action_just_pressed(player_actions.jump):
		# Can if one the floor or briefly if fall off cliff
		if agent.is_on_floor() or coyote_timer.time_left:
			jump = true
	
		# if falling and not on the floor
		if agent.velocity.y >= 0 and not agent.is_on_floor():
			jump_buffer_timer.start()
			
		# in on a wall
		if agent.is_on_wall(): # or $Timers/Movement/WallJumpBuffer.time_left or:
			pass
			#jump = true
	if Input.is_action_just_released("jump") and (not agent.is_on_floor()) and agent.velocity.y < 0:
		faster_fall = true
	
	if Input.is_action_just_pressed(player_actions.ability1) and aim_released:
		aim_press_timer.start()
		aim_released = false
		
	if Input.is_action_just_released(player_actions.ability1):
		#print("player input: release z | still pressed? ", Input.is_action_pressed(player_actions.ability1))
		if not aim_press_timer.is_stopped():
			aim_press_timer.stop()
			aim_released = true
			attack_pressed = true
			_process_celspike_input()
		else:
			aim_released = true
			blackboard.set_var(BBNames.is_aiming_var, false)
	
	var enemy_marked : bool = PlayerKit.marked_enemy != null and is_instance_valid(PlayerKit.marked_enemy) 
	if Input.is_action_just_pressed(player_actions.dash) and (cel_spike_detector.in_range_celspike() or enemy_marked) and not is_dashing:
		is_dashing = true
		_process_spike_dash()

	if Input.is_action_just_pressed("test_button"):
		SignalBus.player_die.emit()
	
	if Input.is_action_just_pressed("ability2") and (not is_sword) and (limbo_hsm.get_active_state() != aim_state):
		_process_sword_input()

func _process_celspike_input():
	#print("INSIDE PROCESS ATTACK")
	if not attack_pressed or (limbo_hsm.get_active_state() == cel_spike_state):
		return
	if not PlayerKit.try_consume_celspike():
		agent.show_floating_label("Cel-Spike not ready!")
		return
	limbo_hsm.dispatch("do_celspike")
	attack_pressed = false

func _process_spike_dash():
	limbo_hsm.dispatch("dashing")

func _process_sword_input():
	if limbo_hsm.get_active_state() == sword_state:
		attack_buffer_timer.start()
	else:
		limbo_hsm.dispatch("swording")

func _on_aim_press_timer_timeout() -> void:
	#print("time out")
	#print("aim released : ", aim_released)
	blackboard.set_var(BBNames.is_aiming_var, true)
	limbo_hsm.dispatch("aim")

func _unhandled_input(event: InputEvent) -> void:
	pass
