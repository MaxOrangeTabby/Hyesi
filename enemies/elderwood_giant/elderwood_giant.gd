extends Enemy



@export var gravity : float = 4000
@export var anim_player : AnimationPlayer
@export var bt_player : BTPlayer
@export var sprite : Sprite2D

@export var collider : CollisionShape2D
@export var attack_hitboxes : Node2D
@export var attack_stuff : Node2D
@export var friction : float = 4700


@export var start_position: Vector2
@export var hover_timer : Timer

var smash_anim : String = "smash"
var punch_anim : String = "punch"
var charge_anim : String = "charge"
var jump_anim : String = "jump"
var term_vel : float = 2000



var blackboard : Blackboard 
var is_active : bool = false
var player : CharacterBody2D
var player_in_melee_range : bool = false
var prev_direction : Vector2
var camera_shake_strength : float = 30
var hovering : bool = false



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
	
	apply_grav(delta)
	apply_friction(delta)
	move_and_slide()

func apply_friction(delta : float) -> void:
	velocity.x = move_toward(velocity.x, 0, friction * delta)

func apply_grav(delta : float) -> void:
	if is_on_floor() or hovering:
		return
	velocity.y = min(velocity.y + gravity * delta, term_vel)

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
		return null

func get_player() -> CharacterBody2D:
	if player: 
		return player
	return null


func stomp_shake() -> void:
	SignalBus.trigger_camera_shake.emit(camera_shake_strength)

func handle_death() -> void:
	var loot_count : int = randi_range(1, loot_spawn_count)
	for i in loot_count: 
		var item_inst = DROPPED_ITEM_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(item_inst)
		item_inst.global_position = global_position
	
	queue_free.call_deferred()


func _on_in_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_melee_range = true


func _on_in_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_melee_range = false

var jump_str : float = -4000
var smash_speed : float = 3500

func smash_attack() -> void:
	blackboard.set_var("can_change_dir", false)
	
	hovering = true
	anim_player.play(jump_anim)
	#velocity.y = -4000.0
	var tween : Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)

	tween.set_ease(Tween.EASE_OUT)

	var dive_pos = player.global_position 
	tween.tween_property(self, "global_position", Vector2(dive_pos.x, global_position.y -400), 1.15)
	await tween.finished

	var tween2 : Tween = create_tween()
	tween2.set_trans(Tween.TRANS_EXPO)
	tween2.tween_property(self, "velocity", velocity + Vector2(0, 4350), .65)
	await tween2.finished
	anim_player.play(smash_anim)


	
	if anim_player.is_playing() and anim_player.current_animation == smash_anim:
		await anim_player.animation_finished
	
	blackboard.set_var("can_change_dir", true)

func punch_attack() -> void:
		anim_player.play(charge_anim)

func punch_dash() -> void:
	blackboard.set_var("can_change_dir", false)
	var tween2 : Tween = create_tween()
	tween2.set_trans(Tween.TRANS_EXPO)
	var x_dir : float = blackboard.get_var("curr_x_dir")
	tween2.tween_property(self, "velocity", velocity + Vector2(4000 * x_dir, 0), .85)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == charge_anim:
		anim_player.play(punch_anim)
