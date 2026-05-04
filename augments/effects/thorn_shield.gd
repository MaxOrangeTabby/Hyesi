class_name ThornShield
extends AugmentEffect

# info {enemy node ref, damage_taken, damage_done}
func apply_effect(info : Dictionary) -> void:	
	var damage_taken : float = info.damage_taken
	var thorn_dmg : float = .15 * damage_taken
	var enemy : Enemy = info.enemy
	
	if enemy == null or (not is_instance_valid(enemy)):
		return
	enemy.process_damage(thorn_dmg, 1.0, 0)
	
func get_desc() -> String:
	var desc : String = "15% of incoming damage gets reflected to enemy.\n -15% Movement Speed"
	return desc
	
