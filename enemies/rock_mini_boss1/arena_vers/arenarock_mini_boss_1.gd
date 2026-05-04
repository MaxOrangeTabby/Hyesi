extends RockGolem

const ROCKLING_SCENE : PackedScene = preload("uid://d0dnp56dnipy6")
const SPIRE_SCENE: PackedScene = preload("uid://btk2o578qpnnm")

@export var wave_count : int = 3
@export var wave_timer : Timer
@export var spire_timer : Timer


var is_active : bool = false
var start_position : Vector2
var wave_spawn_distance : float = 150
var _phase : int = 0

func _ready() -> void:
	super._ready()
	start_position = global_position
	wave_timer.timeout.connect(spawn_wave)
	spire_timer.start()

func _process(delta: float) -> void:
	if not is_active:
		return
	super._process(delta)
	_check_phase()

func activate_fight(_player : CharacterBody2D) -> void:
	if is_active:
		return
	is_active = true
	player = _player
	player_in_range = true
	_phase = 0
	wave_timer.start()

func reset_fight() -> void:
	hp = max_hp
	global_position =  start_position
	velocity =  Vector2.ZERO
	is_active =  false
	player = null
	player_in_range = false
	player_in_attack_range = false
	attacking = false
	_phase = 0
	wave_timer.stop()
	

func _check_phase() -> void:
	var hp_pct : float = hp / max_hp
	if _phase == 0 and hp_pct < 0.66:
		_phase  =1
		spawn_wave()
	elif _phase == 1 and hp_pct < .33:
		_phase = 2
		wave_count = 5
		wave_timer.wait_time = 3.0

func spawn_spire() -> void:
	if not is_active or player == null:
		return
	var spire : Node2D = SPIRE_SCENE.instantiate()
	spire.player = player
	spire.source_enemy = self
	get_tree().current_scene.add_child(spire)

func spawn_wave() -> void:
	if not is_active:
		return
	for i in wave_count:
		var r : Node2D = ROCKLING_SCENE.instantiate()
		get_tree().current_scene.add_child(r)
		r.max_hp = 400.0
		r.scale = Vector2(.4,.4)
		var offset_x : float = randf_range(-50, 50)
		var offset_y : float = randf_range(-50, 0)
		var dir : Vector2 = Vector2(1, 0)
		if player: 
			dir = (player.global_position - global_position).normalized()
		r.global_position = global_position + (dir * wave_spawn_distance) + Vector2(offset_x, offset_y)
	SignalBus.trigger_camera_shake.emit(14.0)


func _on_spire_timer_timeout() -> void:
	for i in wave_count:
		spawn_spire()
	spire_timer.start()
