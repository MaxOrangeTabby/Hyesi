extends SharedState

@export var run_anim_name : StringName = "run"
@export var idle_anim_name : StringName = "idle"
@export var fall_grace_timer : Timer

func _enter() -> void:
	pass
	#print("IN GROUND STATE \n")

func _update(delta: float) -> void:
	if not agent.is_on_floor():
		if agent.velocity.y < 0.0:
			dispatch("in_air")
		if fall_grace_timer.is_stopped():
			fall_grace_timer.start()
		
	var velocity = move(delta)
	# print("velcoity: ", velocity)
	if is_zero_approx(velocity.x):
		anim_player.play(idle_anim_name)
	else:
		anim_player.play(run_anim_name)
		


func _on_fall_grace_timer_timeout() -> void:
	#rint("TIME OUT")
	if not is_active():
		return
	if not agent.is_on_floor():
		dispatch("in_air")
