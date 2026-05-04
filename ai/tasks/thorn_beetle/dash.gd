extends BTAction

const BBVars = BBNames.EnemyBBNames

@export var dash_speed : float = 700
@export var dash_anim_name : StringName = "dash"
@export var dash_duration: float = 1.5

var elapsed_t : float = 0.0

func _enter() -> void:
	var x_dir : int = blackboard.get_var(BBVars.x_dir_var)
	agent.velocity.x = x_dir * dash_speed


func _tick(delta: float) -> Status:
	elapsed_t += delta
	
	var x_dir : int = blackboard.get_var(BBVars.x_dir_var)
	var edge_ahead : bool = false
	if x_dir > 0 and not agent.r_raycast.is_colliding():
		edge_ahead = true
	if x_dir < 0 and not agent.l_raycast.is_colliding():
		edge_ahead = true

	if edge_ahead:
		agent.velocity.x = 0
		return SUCCESS
	
	if elapsed_t > dash_duration:
		return SUCCESS
	
	return RUNNING
