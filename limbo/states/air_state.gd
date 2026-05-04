extends SharedState

var falling_anim_played : bool = false

func _enter() -> void:
	#print("air state")
	if agent.velocity.y < 0:
		anim_player.play("jump")
	else:
		falling_anim_played = true
		anim_player.play("falling")

func _update(delta : float) -> void: 
	if agent.velocity.y >= 0 && not falling_anim_played:
		anim_player.play("falling")
		falling_anim_played = true
		
	# player lands on floor
	if agent.is_on_floor():
		dispatch("landing")
	move(delta)

func _exit() -> void:
	falling_anim_played = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "jump" && not falling_anim_played:
		anim_player.play("falling")
		falling_anim_played = true
