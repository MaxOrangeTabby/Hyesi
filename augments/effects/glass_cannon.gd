class_name GlassCannon
extends AugmentEffect

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:	
	pass

func get_desc() -> String:
	var desc : String = "+40% ATK\n-20% Max HP"
	return desc
	
