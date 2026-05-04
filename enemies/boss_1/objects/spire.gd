class_name Spire
extends Node2D

@export var anim_player : AnimationPlayer
@export var erupt_anim_name : String = "erupt"

var source_enemy : Enemy = null
var player : CharacterBody2D
var spawn_position : Vector2 = Vector2(0,0)

func _ready() -> void: 
	if player:
		#print("GOT PLAYER, SPAWNING SPIRE")
		var spawn_position : Vector2 = Vector2(player.global_position.x, 700)
		global_position = spawn_position
		await get_tree().create_timer(1.0).timeout
		anim_player.play(erupt_anim_name)

func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == erupt_anim_name:
		queue_free()
