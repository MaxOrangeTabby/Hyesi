extends BTAction

@export var damage : int = 2
@export var dash_anim_name : StringName = "dash"

var anim_player : AnimationPlayer
var dash_speed : float =  3700

func _setup() -> void:
	anim_player = agent.get_anim_player()
	
	
func _enter() -> void:
	#print("IN DASH GD current x dir: ", blackboard.get_var("curr_x_dir"))
	agent.velocity.x = dash_speed * blackboard.get_var("curr_x_dir")
	anim_player.play(dash_anim_name)

func _tick(delta: float) -> Status:
	if anim_player.is_playing() and anim_player.current_animation == dash_anim_name:
		return RUNNING
	return SUCCESS

func _exit() -> void:
	#print("SET CAN CHANGE TO TRUE")
	pass
