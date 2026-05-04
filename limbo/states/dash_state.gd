extends SharedState

@export var cel_spike_detector : Area2D
@export var dash_anim_name : StringName 
@export var dash_speed : float = 3500
@export var dash_friction : float = 8000

@export var main_sprite : Sprite2D

var direction : Vector2
var rotation_angle : float
var flipped_sprite : bool = false

const COLLIDE_ENEMY_LAYER : int = 8

func _enter() -> void:
	var target : Node2D = _find_target()
	print("dash state - target: ", target)
	
	if target == null:
		if agent.is_on_floor():
			dispatch("on_ground")
		else:
			dispatch("in_air")
		return
		
	agent.set_collision_mask_value(COLLIDE_ENEMY_LAYER, false)
	
	direction = target.global_position - agent.global_position
	direction = direction.normalized()
	rotation_angle = direction.angle()
	
	#can youprint("dash state - dir: ", direction)
	
	var rotation_angle_deg = rad_to_deg(rotation_angle)
	if rotation_angle_deg > 90.0 || rotation_angle_deg < -90.0:
		#main_sprite.flip_h = true
		#flipped_sprite = true
		if rotation_angle_deg > 90.0 && rotation_angle_deg < 180:
			rotation_angle_deg -= 180
		else:
			rotation_angle_deg += 180
	rotation_angle = snappedf(deg_to_rad(rotation_angle_deg), .01)
	agent.rotation = rotation_angle
	
	anim_player.play(dash_anim_name)
	agent.velocity = (direction * dash_speed) + Vector2(0, -700)
	
	var max_x_mag : float = player_stats.player_max_velocity.x
	var max_y_mag : float = player_stats.player_max_velocity.y
	agent.velocity.x = clampf(agent.velocity.x, -max_x_mag, max_x_mag)
	agent.velocity.y = clampf(agent.velocity.y, -max_y_mag, max_y_mag)
	
	agent.friction = dash_friction
	agent.move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update(delta: float) -> void:
	agent.velocity.x = move_toward(agent.velocity.x, 0, dash_friction * delta)

	if not anim_player.is_playing():
		if agent.is_on_floor():
			dispatch("on_ground")
		elif not agent.is_on_floor():
			dispatch("in_air")
	agent.move_and_slide()

func _exit() -> void:
	restore_movement_stats()
	agent.set_collision_mask_value(COLLIDE_ENEMY_LAYER, true)

	if flipped_sprite:
		flipped_sprite = false
		main_sprite.flip_h = false

	agent.rotation = 0.0
	agent.velocity = Vector2(0,0)
	blackboard.set_var(BBNames.is_dashing, false)

func _find_target() -> Node2D:
	if PlayerKit.marked_enemy and is_instance_valid(PlayerKit.marked_enemy):
		#print("DASH STATE: GOING TO ENEMYdddd")

		var target_enemy : Enemy = PlayerKit.marked_enemy
		PlayerKit.marked_enemy.set_marked_visual(false)
		PlayerKit.marked_enemy = null
		if target_enemy is Enemy:
			var dir : Vector2 = (agent.global_position - target_enemy.global_position).normalized()
			target_enemy.process_damage(PlayerKit.handle_out_damage(target_enemy), 1.04, 24, dir)
		return target_enemy
	else:
		#print("DASH STATE: GOING TO SPIKE")
		var cel_spike : CharacterBody2D = cel_spike_detector.get_cel_spike()
		if cel_spike:
			return cel_spike
	return null # if nothign was found

# Let the agent handle restoring stats
func restore_movement_stats() -> void:
	agent.recalc_stats()
