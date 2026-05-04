extends SharedState

@export var sword_anim_name_arr: Array[StringName] = ["attack1", "attack2", "attack3"]
@export var attack_buffer_timer : Timer
@export var combo_reset_timer : Timer

@export var speed_mult : float = .5
@export var gravity_mult : float = .95

@export var attack_area : Area2D

const WINDBLADE_SCENE : PackedScene = preload("uid://dicnknmh5vjth")

var current_anim_idx : int = 0
var damp_tween : Tween


func _enter() -> void:
	# stop the combo reset timer where it is
	anim_player.speed_scale = PlayerKit.atk_spd
	#print("animation player speed scale", anim_player.speed_scale)
	
	agent.speed = player_stats.player_velocity * speed_mult
	agent.gravity = player_stats.player_gravity * gravity_mult
	agent.friction = player_stats.player_friction * 3.5
	
	if damp_tween and damp_tween.is_running():
		damp_tween.kill()
	damp_tween = create_tween()
	damp_tween.tween_property(agent, "velocity:y", agent.velocity.y * .85, .2)

	combo_reset_timer.stop()
	play_sword_anim()
	SFX.play_2d(SFXType.TYPES.MC_SLASH, agent)
	
	if not anim_player.animation_finished.is_connected(_animation_finished):
		anim_player.animation_finished.connect(_animation_finished)
	


func _update(delta: float) -> void:
	if agent.is_on_floor():
		agent.speed = player_stats.player_velocity * .15
	elif not agent.is_on_floor():
		agent.speed = player_stats.player_velocity * speed_mult
	move(delta)


func _exit() -> void:
	anim_player.speed_scale = 1.0
	
	if anim_player.animation_finished.is_connected(_animation_finished):
		anim_player.animation_finished.disconnect(_animation_finished)
	
	if attack_area:
		attack_area.reset_colliders()
		
	# times for the next attack to be close enough
	combo_reset_timer.start()
	restore_movement_stats()


func play_sword_anim() -> void:
	current_anim_idx  = current_anim_idx % sword_anim_name_arr.size()
	anim_player.play(sword_anim_name_arr[current_anim_idx])
	current_anim_idx  = (current_anim_idx + 1) % sword_anim_name_arr.size()

	if PlayerKit.has_windblade:
		_spawn_windblade_wave()

func _on_combo_reset_timer_timeout() -> void:
	current_anim_idx = 0


func _animation_finished(anim_name: StringName) -> void:
	if not is_active():
		return
	if attack_buffer_timer.time_left > 0.0:
		attack_buffer_timer.stop()
		play_sword_anim()
		return
	if agent.is_on_floor():
		dispatch("on_ground")
	elif not agent.is_on_floor():
		dispatch("in_air")

# Let the agent handle restoring stats
func restore_movement_stats() -> void:
	agent.recalc_stats()

func _spawn_windblade_wave() -> void:
	var wave_inst = WINDBLADE_SCENE.instantiate()
	var dir : Vector2 = Vector2(sign(agent.flip_root.scale.x),0)
	agent.get_tree().current_scene.add_child(wave_inst)
	wave_inst.direction = sign(dir)
	wave_inst.scale.x = sign(dir.x)
	wave_inst.global_position = agent.global_position
