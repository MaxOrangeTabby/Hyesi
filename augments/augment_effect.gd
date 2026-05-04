class_name AugmentEffect
extends Resource

enum EffectType {ON_KILL, ON_HIT, ON_DAMAGED, PASSIVE}

@export var effect_type : EffectType


# FOR SUBCLASSES TO OVERRIDE
# DICTIONARY {"enemy" : Node2D, "damage_taken" : int, "damage_done" : float}
func apply_effect(info : Dictionary) -> void:
	pass

func apply_passive() -> void:
	pass

func get_desc()  -> String:
	return "to be filled"

func reset_apply()-> void:
	pass
