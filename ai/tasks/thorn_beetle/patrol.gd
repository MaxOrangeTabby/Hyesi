extends BTAction

const BBVars = BBNames.EnemyBBNames
@export var walk_anim_name : StringName = "walk"
@export var walk_speed : float = 400


var dir : int = 1

func _enter() -> void:
	var x_dir : int = blackboard.get_var(BBVars.x_dir_var)
	if x_dir and x_dir != 0:
		dir = x_dir
	agent.face_dir(Vector2(dir, 0))
	agent.anim_player.play(walk_anim_name)

func _tick(delta: float) -> Status:
	agent.velocity.x = dir * walk_speed
	if dir > 0 and not agent.r_raycast.is_colliding():
		dir = -1
		agent.face_dir(Vector2(dir, 0))
		blackboard.set_var(BBVars.x_dir_var, dir)

	elif dir < 0 and not agent.l_raycast.is_colliding():
		dir = 1
		agent.face_dir(Vector2(dir, 0))
		blackboard.set_var(BBVars.x_dir_var, dir)
	
	return RUNNING
