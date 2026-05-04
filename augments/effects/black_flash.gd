class_name BlackFlash
extends AugmentEffect

const TRIGGER_CAP : int  = 10
var hit_count : int = 0


# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:
	hit_count += 1
	if hit_count % TRIGGER_CAP != 0:
		return
	
	var enemy : Enemy = info.enemy
	if enemy == null or (not is_instance_valid(enemy)):
		return
	
	var damage_done : float = info.damage_done
	
	
	var black_flash_dmg = 1.5 * damage_done
	enemy.process_damage(black_flash_dmg, 1.1, 14)
	SignalBus.spawn_vfx.emit(VFXType.TYPES.BLACK_FLASH, enemy)

func get_desc() -> String:
	var desc : String = "After every 9 attacks, the 10th deals 2.5x damage.\n -15% ATK"
	return desc
	
