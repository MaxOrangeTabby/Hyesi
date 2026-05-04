extends SharedState

@export var aim_cursor : Sprite2D
@export var aim_cursor_radius : float = 400.0
@export var player_actions : PlayerActions

@export var cel_spike_scene : PackedScene
@export var spike_float_timer : Timer

func _enter() -> void:
	#print(">> AIM ENTER")
	spike_float_timer.stop()
	aim_cursor.visible = true
	update_cursor()
	
	SignalBus.start_time_slow.emit(.3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update(delta: float) -> void:
	update_cursor()
	
	if Input.is_action_just_released(player_actions.ability1):
		if agent.is_on_floor():
			dispatch("on_ground")
		elif not agent.is_on_floor():
			dispatch("in_air")
	
	if Input.is_action_just_pressed(player_actions.ability2):
		#print("LEFT CLCIK")
		if not PlayerKit.try_consume_celspike():
			agent.show_floating_label("Cel-Spike not ready!")
			return
		var mouse_pos : Vector2 = agent.get_global_mouse_position()
		var direction : Vector2 = mouse_pos - agent.global_position
		direction = direction.normalized()
		
		var cel_spike = cel_spike_scene.instantiate()
		var agent_x_dir = blackboard.get_var(BBNames.x_direction_var)
		cel_spike.global_position = agent.global_position + (Vector2(200.0, 200.0) * direction)
		cel_spike.init_dir = direction
		cel_spike.is_focused = true
		
		#print("direction angle: ", rad_to_deg(direction.angle()))
		add_child.call_deferred(cel_spike)
		
		if agent.is_on_floor():
			dispatch("on_ground")
		elif not agent.is_on_floor():
			dispatch("in_air")

func update_cursor() -> void: 
		var mouse_pos : Vector2 = agent.get_global_mouse_position()
		var direction : Vector2 = mouse_pos - agent.global_position
		direction = direction.normalized()
		
		var lever_arm : Vector2 = direction * aim_cursor_radius
		aim_cursor.position = lever_arm
		aim_cursor.rotation = direction.angle()
		

func _exit() -> void:
	#print("<< AIM EXIT")       
	blackboard.set_var(BBNames.is_aiming_var, false)
	aim_cursor.visible = false
	
	SignalBus.reset_time_slow.emit()
	
	agent.velocity = Vector2.ZERO
	agent.gravity = player_stats.player_float_gravity
	spike_float_timer.start()
