class_name Duelist
extends AugmentEffect

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:	
	pass

func get_desc() -> String:
	var desc : String = "+35% crit damage\n−15% move speed"
	return desc
	
