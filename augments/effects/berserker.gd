class_name Berserker
extends AugmentEffect

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:	
	pass

func get_desc() -> String:
	var desc : String = "+30% atk\n+20% atk speed\n−40% crit rate"
	return desc
	
