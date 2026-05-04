class_name Featherweight
extends AugmentEffect

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:	
	pass

func get_desc() -> String:
	var desc : String = "−30% max HP\n+25% move speed\n+20% atk speed"
	return desc
	
