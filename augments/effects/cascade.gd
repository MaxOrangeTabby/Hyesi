class_name Cascade
extends AugmentEffect

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:	
	var enemy : Enemy = info.enemy
	if enemy == null or (not is_instance_valid(enemy)):
		return
	var damage_done : float = info.damage_done
	
	var cascade_dmg : float = .45 * damage_done
	enemy.process_damage(cascade_dmg, 0.0, 8)
	SignalBus.spawn_vfx.emit(VFXType.TYPES.CASCADE, enemy)

func get_desc() -> String:
	var desc : String = "Attacks trigger an additional one at 45% damage.\n-20% Attack Speed"
	return desc
	
