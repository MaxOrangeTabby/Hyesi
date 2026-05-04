extends Enemy

enum State {HOVER, APPROACH, ATTACK}

@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer
@export var blast_anim_name : String = "blast"

@export var bob_amp : float = 2.5
@export var bob_freq : float = 2
@export var bob_phase : float = 10

@export var attack_cd_timer : Timer
@export var wasp_blast_scene : PackedScene

@export var attack_distance : float = 1200
@export var min_distance : float = 500
@export var approach_speed : float = 300
@export var hover_speed : float = 120
@export var acceleration : float = 400
@export var fly_radius : float = 100

@export var blast_marker : Marker2D
@export var collision_shape : CollisionShape2D


var player : CharacterBody2D 
var is_active : bool 
var state : State = State.HOVER
var spawn_pos : Vector2
var hover_target : Vector2

func _ready() -> void:
	hp = max_hp
	
	hover_target = global_position
	spawn_pos = global_position
	
	var scaled_shape_rad : float = scale.x * collision_shape.shape.radius
	min_distance = .25 * scaled_shape_rad
	attack_distance = .85 * scaled_shape_rad

func _process(delta: float) -> void:
	bob_phase += delta * bob_freq
	match state:
		State.HOVER : _hover_state(delta)
		State.APPROACH : _approach_state(delta)
		State.ATTACK : _attack_state(delta)
	velocity.y += sin(bob_phase) * bob_amp
	move_and_slide()

func face_dir(dir : Vector2):
	if dir.x == 0:
		return
	sprite.flip_h = dir.x < 0

func _hover_state(delta : float) -> void:
	if player:
		state = State.APPROACH
		return
	var dir_to_target : Vector2 = hover_target - global_position
	if dir_to_target.length() <= 20:
		get_hover_location()
		dir_to_target = hover_target - global_position
	var dir_target_norm : Vector2 = dir_to_target.normalized()
	velocity = velocity.move_toward(dir_target_norm * hover_speed, delta * acceleration)

func _attack_state(delta : float) -> void:
	print("IN ATTACK STATE")
	if not player or attack_cd_timer.time_left:
		state = State.HOVER
		return
	var direction_to_player : Vector2 = player.global_position - global_position
	face_dir(direction_to_player)
	anim_player.play(blast_anim_name)
	attack_cd_timer.start()
	state = State.APPROACH

func _approach_state(delta : float) -> void:
	if not player: 
		state = State.HOVER
		return
	
	var dir_to_player : Vector2 = player.global_position - global_position
	var dist_to_player : float = dir_to_player.length()
	face_dir(dir_to_player)
	var norm_dir_to_player : Vector2 = dir_to_player.normalized()

	var focus_vel : Vector2 
	if dist_to_player <= min_distance:
		norm_dir_to_player = - norm_dir_to_player
		focus_vel = norm_dir_to_player * approach_speed
	elif dist_to_player <= attack_distance:
		focus_vel = Vector2.ZERO
		if attack_cd_timer.is_stopped():
			state = State.ATTACK
	else:
		focus_vel = norm_dir_to_player * approach_speed
	velocity = velocity.move_toward(focus_vel, acceleration * delta)

func _spawn_blast() -> void:
	if player:
		var dir_to_player : Vector2 = player.global_position - global_position
		var blast_inst = wasp_blast_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(blast_inst)
		blast_inst.global_position = blast_marker.global_position
		blast_inst.dir = dir_to_player.normalized()
		blast_inst.source_enemy = self

func get_hover_location() -> void:
	hover_target = spawn_pos + Vector2(
		randf_range(-fly_radius, fly_radius),
		randf_range(-fly_radius, fly_radius)
	)

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player = body


func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player = null


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == blast_anim_name:
		_spawn_blast()

func handle_death() -> void:
	var loot_count : int = randi_range(1, loot_spawn_count)
	for i in loot_count: 
		var item_inst = DROPPED_ITEM_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(item_inst)
		item_inst.global_position = global_position
	
	queue_free.call_deferred()
