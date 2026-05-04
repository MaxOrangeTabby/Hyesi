extends SharedState

@export var air_attack_anim_name : StringName = "run"
@export var ground_attack_anim_name : StringName = "idle"
@export var cel_spike_scene : PackedScene
@export var limbo_hsm : LimboHSM
@export var cel_spike_particles : GPUParticles2D




func _enter() -> void:
	#activate cel spike particles
	#cel_spike_particles.restart()
	#cel_spike_particles.emitting = true
	
	var cel_spike = cel_spike_scene.instantiate()
	var agent_x_dir = blackboard.get_var(BBNames.x_direction_var)
	cel_spike.global_position = agent.global_position + Vector2(100.0 * agent_x_dir, 0)
	cel_spike.init_dir = Vector2(agent_x_dir, 0)
	
	
	SFX.play_2d(SFXType.TYPES.CELSPIKE_FIRE, cel_spike)

	add_child.call_deferred(cel_spike)
	
	#print("INSIDE ATTACK STATE")
	get_tree().create_timer(.25).timeout.connect(func():
		if not is_active():
			return
		dispatch("on_ground")
	)
	
func _update(delta: float) -> void:
	var velocity = move(delta)
	
	
