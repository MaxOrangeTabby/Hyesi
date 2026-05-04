class_name SharedState
extends LimboState

@export var anim_player : AnimationPlayer
@export var anim_name : StringName
@export var coyote_timer : Timer 
@export var jump_buffer_timer : Timer 

@onready var player_stats : PlayerStats = preload("uid://cp6r1ymxhicix")

func move(delta : float) -> Vector2:
	var direction : Vector2 = blackboard.get_var(BBNames.direction_var)
	
	if(direction.x and blackboard.get_var(BBNames.can_move_var)):
		if(direction.x * agent.velocity.x < 0): #opposite direction of current velocity
			agent.acceleration = 17500
		else:
			agent.acceleration = player_stats.player_acceleration * PlayerKit.move_speed
		agent.velocity.x = move_toward(agent.velocity.x ,direction.x * agent.speed, agent.acceleration * delta)
	else:
		agent.velocity.x = move_toward(agent.velocity.x, 0, agent.friction * delta)
		
	if blackboard.get_var(BBNames.jump_var) or (jump_buffer_timer.time_left and agent.is_on_floor()):
		agent.velocity.y -= agent.jump_strength
		blackboard.set_var(BBNames.jump_var, false)
		blackboard.set_var(BBNames.faster_fall_var, false)

	agent.velocity = agent.velocity.clamp(agent.velocity, player_stats.player_max_velocity)
	var max_x_mag : float = player_stats.player_max_velocity.x
	var max_y_mag : float = player_stats.player_max_velocity.y
	
	agent.velocity.x = clampf(agent.velocity.x, -max_x_mag, max_x_mag)
	agent.velocity.y = clampf(agent.velocity.y, -max_y_mag, max_y_mag)
	
	blackboard.set_var(BBNames.on_floor_var, agent.is_on_floor())
	agent.move_and_slide()
		
	# player WAS on floor but now is not and is falling
	if blackboard.get_var(BBNames.on_floor_var) and not agent.is_on_floor() and agent.velocity.y >= 0:
		coyote_timer.start()
	return agent.velocity


	
