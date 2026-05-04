extends BTAction

@export var chase_speed : float = 1500
@export var walk_anim_name : StringName = "walk"
const BBVars = BBNames.EnemyBBNames

var x_dir : int = 1

func _enter() -> void:
	agent.anim_player.play(walk_anim_name)

func _tick(delta: float) -> Status:	
	if blackboard.get_var(BBVars.player_ref_var):
		var player : Node2D = blackboard.get_var(BBVars.player_ref_var)
		var direction_to_player : Vector2 = player.global_position - agent.global_position
		if not is_zero_approx(direction_to_player.x):
			agent.face_dir(direction_to_player)
			x_dir = sign(direction_to_player.x)
			blackboard.set_var(BBVars.x_dir_var, x_dir)
			
		var edge_ahead : bool = false
		if x_dir > 0 and not agent.r_raycast.is_colliding():
			edge_ahead = true
		if x_dir < 0 and not agent.l_raycast.is_colliding():
			edge_ahead = true
		if edge_ahead:
			agent.velocity.x = 0
			return FAILURE
	
	agent.velocity.x = chase_speed * x_dir
	return RUNNING
