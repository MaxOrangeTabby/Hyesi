class_name AbsoluteFocus
extends AugmentEffect

# info {enemy node ref, damage_taken, damage_done}
func apply_passive() -> void:
	PlayerKit.charged_celspike_dmg_mult = 1.3
	PlayerKit.charged_celspike_cd_mult = .7
	pass

func get_desc() -> String:
	var desc : String = "[F Hold] focused cel-spike shots do 30% more damage and recharge 30% faster. \n -25% Attack Speed"
	return desc
	

func reset_apply() -> void: 
	PlayerKit.charged_celspike_dmg_mult = 1.0
	PlayerKit.charged_celspike_cd_mult = 1.0
