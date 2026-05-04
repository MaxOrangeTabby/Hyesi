extends BTAction

var spire_mark_anim_name : String = "charge_mark"
var spire_mark_anim_player : AnimationPlayer
var spire_mark : PackedScene = preload("uid://csw54t5frew4q")
var spire : PackedScene = preload("uid://btk2o578qpnnm")
var player : CharacterBody2D

var spire_mark_instance
var spire_instance
var spawned_spike : bool = false

func _setup() -> void:
	pass

func _enter() -> void:
	#print("spawned spike: ", spawned_spike)
	spawned_spike = false
	player = agent.get_player()
	spire_mark_instance = spire_mark.instantiate()
	spire_mark_instance.player = player
	
	agent.add_child(spire_mark_instance)
	spire_mark_anim_player = spire_mark_instance.get_anim_player()
	
	spire_instance = spire.instantiate()
	spire_instance.player = player
	spire_instance.source_enemy = agent


func _tick(delta: float) -> Status:
	if spire_mark_anim_player:
		if spire_mark_anim_player.is_playing() and spire_mark_anim_player.current_animation == spire_mark_anim_name:
			return RUNNING
	
	if not spawned_spike:
		spawned_spike = true
		spawn_spike()
	return SUCCESS

func spawn_spike() -> void:
	agent.add_child(spire_instance)
