extends Enemy

@export var anim_player : AnimationPlayer
@export var bt_player : BTPlayer
@export var sprite : Sprite2D
@export var flip_timer : Timer

@export var collider : CollisionShape2D
@export var attack_hitboxes : Node2D
@export var attack_stuff : Node2D
@export var friction : float = 4700

@export var laser_sweep_angle : float = (PI / 4.0)
@export var laser_sweep_duration : float = 1.5
@export var start_position: Vector2

@onready var laser_beam : Node2D = %LaserBeam
@onready var beam_charge : AudioStreamPlayer2D = %BeamCharge
@onready var beam_blast : AudioStreamPlayer2D = %BeamBlast

var flip_tween : Tween
var laser_sweep_tween : Tween


var blackboard : Blackboard 
var is_active : bool = false
var player : CharacterBody2D
var player_in_melee_range : bool = false
var prev_direction : Vector2
var camera_shake_strength : float = 30



func _ready() -> void:
	hp = max_hp
	
	start_position = global_position
	blackboard = bt_player.blackboard
	bt_player.active = false
	blackboard.set_var("can_change_dir", true)

	blackboard.bind_var_to_property("active", self, "is_active")
	blackboard.bind_var_to_property("player_in_range", self, "player_in_melee_range")

func _process(delta: float) -> void:
	if player:
		var direction_to_player : Vector2 = player.global_position - global_position
		if not is_zero_approx(direction_to_player.x):
			face_dir(direction_to_player)
	
	apply_grav()
	apply_friction(delta)
	move_and_slide()

func apply_friction(delta : float) -> void:
	velocity.x = move_toward(velocity.x, 0, friction * delta)

func apply_grav() -> void:
	if is_on_floor():
		return
	velocity.y = 1500

func reset_fight() -> void:
	hp = max_hp
	global_position = start_position
	velocity = Vector2.ZERO
	bt_player.active = false
	is_active = false
	player = null

func activate_fight(_player : CharacterBody2D) -> void: 
	#print("boss1 activaate")
	if is_active: 
		return
	is_active = true
	bt_player.active = true
	player = _player

	
	var direction_to_player : Vector2 = player.global_position - global_position
	var init_dir : int
	if direction_to_player.x != 0.0:
		init_dir = int(sign(direction_to_player.x))
	else:
		init_dir = -1
	prev_direction = Vector2(init_dir, 0)
	blackboard.set_var("curr_x_dir", init_dir)
	sprite.flip_h = init_dir > 0
	attack_stuff.scale.x = -abs(attack_stuff.scale.x) if init_dir > 0 else abs(attack_stuff.scale.x)


func face_dir(dir : Vector2) -> void: 
	#print("current x dir: ", dir.x)
	if not blackboard.get_var("can_change_dir"):
		return
	if not dir.x:
		return
		
	blackboard.set_var("curr_x_dir", sign(dir.x))
	var new_x_dir : int
	if dir.x > 0.0:
		new_x_dir = -1
	else:
		new_x_dir = 1
	
	if sign(attack_stuff.scale.x) == new_x_dir:
		return
	attack_stuff.scale.x = new_x_dir * abs(attack_stuff.scale.x)
	prev_direction.x = dir.x
	sprite.flip_h = dir.x > 0

func get_anim_player() -> AnimationPlayer:
	if anim_player:
		return anim_player
	else:
		#print("ERROR: get_anim_player()")
		return null

func get_player() -> CharacterBody2D:
	if player: 
		#print("returning player")
		return player
	return null

func _on_melee_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_melee_range = true


func _on_melee_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_melee_range = false

func play_laser() -> void: 
	SFX.play_2d(SFXType.TYPES.BEAM_CHARGE, self)

	if flip_tween and flip_tween.is_running():
		flip_tween.kill()
	var curr : int = int(blackboard.get_var("curr_x_dir"))
	var dir_sign : int = -1 if curr > 0 else 1
	attack_stuff.scale.x = float(dir_sign)
	
	if laser_sweep_tween and laser_sweep_tween.is_running():
		laser_sweep_tween.kill()
	laser_beam.rotation = PI - laser_sweep_angle
	laser_sweep_tween = create_tween()
	laser_sweep_tween.tween_property(laser_beam, "rotation", PI, laser_sweep_duration)
	
	beam_charge.play()
	laser_beam.play_laser();
	var laser_shake : float = 16
	SignalBus.trigger_cont_camera_shake.emit(laser_shake)

func stop_laser() -> void:
	if laser_sweep_tween and laser_sweep_tween.is_running():
		laser_sweep_tween.kill()
	laser_beam.rotation = PI
	SignalBus.stop_cont_camera_shake.emit()
	laser_beam.stop_laser()
	

func stomp_shake() -> void:
	SignalBus.trigger_camera_shake.emit(camera_shake_strength)

func handle_death() -> void:
	var loot_count : int = randi_range(1, loot_spawn_count)
	for i in loot_count: 
		var item_inst = DROPPED_ITEM_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(item_inst)
		item_inst.global_position = global_position
	
	queue_free.call_deferred()
