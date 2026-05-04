extends Sprite2D

@export var anim_player : AnimationPlayer
@export var charge_anim_name : String = "charge_mark"
var player : CharacterBody2D

func _ready() -> void:
	anim_player.play(charge_anim_name)

func _process(delta: float) -> void:
	if player:
		global_position = player.global_position + Vector2(0, -120)
		#print("following player")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == charge_anim_name:
		queue_free()

func get_anim_player() -> AnimationPlayer:
	if anim_player:
		return anim_player
	return null
