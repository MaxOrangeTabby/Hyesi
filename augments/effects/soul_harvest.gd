class_name SoulHarvest
extends AugmentEffect

const TRIGGER_CAP : int = 10
var hit_count : int = 0
var heal_prnt : float = .05

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:
	hit_count += 1
	
	if hit_count > TRIGGER_CAP:
		hit_count = 0
	
	if hit_count % TRIGGER_CAP != 0:
		return
	
	hit_count = 0
	
	# HEAL 5% OF MAX HP
	var heal_amount : float = (PlayerKit.hp) * heal_prnt
	SignalBus.player_heal.emit(heal_amount)

func get_desc() -> String:
	var desc : String = "Every 10th hit heals you but -15% max hp"
	return desc
	
