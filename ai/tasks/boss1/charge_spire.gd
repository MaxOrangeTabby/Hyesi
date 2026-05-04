extends BTAction


@export var charge_spire_anim_name : StringName = "charge_spire"

var anim_player : AnimationPlayer
var player : CharacterBody2D

func _setup() -> void:
	anim_player = agent.get_anim_player()

func _enter() -> void:
	player = agent.get_player()

	blackboard.set_var("can_change_dir", false)
	anim_player.play(charge_spire_anim_name)

func _tick(delta: float) -> Status:
	if anim_player.is_playing() and anim_player.current_animation == charge_spire_anim_name:
		return RUNNING
	return SUCCESS

func _exit() -> void:
	blackboard.set_var("can_change_dir", true)
