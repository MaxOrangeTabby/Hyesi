extends Node2D

@onready var anim_player : AnimationPlayer = %AnimationPlayer

var hit1_anim_name : StringName = "hit1"
var hit2_anim_name : StringName = "hit2"
var hit3_anim_name : StringName = "hit3"

var hit_arr : Array[StringName] = [hit1_anim_name, hit2_anim_name, hit3_anim_name]

var anim_names

func play_animation(anim_name : String) -> void:
	#print("vfx player play: ", anim_name)
	
	if anim_player.has_animation(anim_name):
		anim_player.play(anim_name)
	else:
		print("VFX Player: Animation DNE")

func play_random_hit() -> void:
	var random_hit_anim : String = hit_arr.pick_random()
	if anim_player.has_animation(random_hit_anim):
		anim_player.play(random_hit_anim)
	else:
		print("VFX Player animation dne")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
