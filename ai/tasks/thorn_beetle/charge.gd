extends BTAction

@export var charge_anim_name : StringName = "charge"

func _enter() -> void: 
	agent.velocity.x = 0

func _tick(delta: float) -> Status: 
	return SUCCESS
