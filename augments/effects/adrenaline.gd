class_name Adrenaline
extends AugmentEffect

const BUFF_MULT : float = 1.25
const BUFF_DURATION : float = 1.5 # measured in seconds

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:
	PlayerKit.set_temp_move_mult(BUFF_MULT, BUFF_DURATION)

func get_desc() -> String:
	var desc : String = "Attacks speed you up 25% for 1.5 seconds. \n -15% Max Health"
	return desc
	
