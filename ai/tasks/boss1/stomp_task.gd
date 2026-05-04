extends BTAction

@export var damage : int = 1
@export var stomp_anim_name : StringName = "stomp"
var anim_player : AnimationPlayer

func _setup() -> void:
	anim_player = agent.get_anim_player()
	
func _enter() -> void:
	anim_player.play(stomp_anim_name)

func _tick(delta: float) -> Status:
	if anim_player.is_playing() and anim_player.current_animation == stomp_anim_name:
		return RUNNING
	return SUCCESS
	
