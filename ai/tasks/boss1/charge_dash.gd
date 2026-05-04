extends BTAction

@export var damage : int = 1
@export var charge_dash_anim_name : StringName = "charge_dash"
var anim_player : AnimationPlayer

func _setup() -> void:
	anim_player = agent.get_anim_player()
	
func _enter() -> void:
	blackboard.set_var("can_change_dir", false)
	anim_player.play(charge_dash_anim_name)

func _tick(delta: float) -> Status:
	if anim_player.is_playing() and anim_player.current_animation == charge_dash_anim_name:
		return RUNNING
	return SUCCESS

func _exit() -> void:
	blackboard.set_var("can_change_dir", true)
