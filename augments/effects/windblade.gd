class_name Windblade
extends AugmentEffect

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:	
	pass

func get_desc() -> String:
	var desc : String = "Sword slashes launch a wave projectile. \n-15% ATK"
	return desc
	
func apply_passive() -> void:
	PlayerKit.has_windblade = true

func reset_apply()-> void:
	PlayerKit.has_windblade = false
