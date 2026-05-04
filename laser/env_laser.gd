extends Node2D

enum State {CHARGING, FIRING, COOLDOWN}

@export var charge_duration : float = 1.5
@export var fire_duration : float = 1.5
@export var cooldown : float = 2.0
@export var start_active : bool = true

@onready var laser_beam : Node2D = %LaserBeam
@onready var timer : Timer = %Timer
@onready var anim_player : AnimationPlayer = %AnimationPlayer

var state : State = State.COOLDOWN
var charge_anim_name : StringName = "charge_laser"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if start_active:
		_start_charging()


func _on_timer_timeout() -> void:
	match state:
		State.FIRING : _start_cooldown()
		State.COOLDOWN : _start_charging()

func _start_charging() -> void:
	state =  State.CHARGING
	anim_player.play(charge_anim_name)

func _start_fire() -> void:
	state = State.FIRING
	laser_beam.play_laser()
	timer.start(fire_duration)

func _start_cooldown() -> void:
	state = State.COOLDOWN
	laser_beam.stop_laser()
	timer.start(cooldown)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if state == State.CHARGING and anim_name == charge_anim_name:
		_start_fire()
