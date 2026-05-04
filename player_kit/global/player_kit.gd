extends Node


signal stats_updated


# AUGMENT SPECIFIC
signal augments_updated
signal on_hit(info : Dictionary)
signal on_kill(info : Dictionary)
signal on_crit(info : Dictionary)
signal on_damaged(info : Dictionary)


#Cel spike stuffs
signal celspike_charges_changed(current : int, max : int)
const MAX_CELSPIKE_CHARGE : int = 3
const CELSPIKE_RECHARGE_TIME : float = 3 # in seconds
var charged_celspike_dmg_mult : float = 1.0
var charged_celspike_cd_mult : float = 1.0
var celspike_charges : int = MAX_CELSPIKE_CHARGE
var celspike_recharging : bool = false

#var augments : Array[Augment] 
var perm_augments : Array[Augment]
var temp_augments : Array[Augment]
var marked_enemy : Enemy = null

var has_windblade : bool = false

# Physics Player Stats
const player_stats : PlayerStats = preload("uid://cp6r1ymxhicix")

# HANDLES THE PLAYER CURRENT STATS
var equipped_items : Dictionary[Item.ItemType, Item] = {
	Item.ItemType.WEAPON : null,
	Item.ItemType.CIRCLET : null,
	Item.ItemType.PENDANT : null,
}

# CONSTANTS ----------------------- 
# HEALTH IS IN SINGLE POINTS
const BASE_HP : float = 100
const BASE_ATK : int = 10
const BASE_ATK_SPD : float = 1.25 # ATTACK PER SECOND

# ALL PERCENTAGE BASED
const BASE_CRIT_RATE : float = 7.0
const BASE_CRIT_DMG : float = 115.0 # 100 % BASEMULTIPLIER
const BASE_MOVE_SPD : float = 1.0
# ----------------------------------

# BONUSES ----------------------- 
# FLAT BASED
var bonus_hp: int = 0
var bonus_atk : int = 0

# ALL PERCENTAGE BASED
# ATTACK PER SECOND
var bonus_crit_rate : float = 0.0
var bonus_crit_dmg : float = 0.0 
# ----------------------------------

# MULTIPLIERS - 1 is no change
var mult_hp : float = 1.0
var mult_atk : float = 1.0
var mult_atk_spd : float = 1.0
var mult_move_spd : float = 1.0
var mult_move_spd_temp : float = 1.0

var hp : float:
	get: return (BASE_HP + bonus_hp) * mult_hp

var atk : float:
	get: return (BASE_ATK + bonus_atk) * mult_atk

var atk_spd : float:
	get: return (BASE_ATK_SPD * mult_atk_spd)

var crit_rate : float:
	get: return (BASE_CRIT_RATE + bonus_crit_rate)

var crit_dmg : float:
	get: return (BASE_CRIT_DMG + bonus_crit_dmg)

var move_speed : float:
	get: return (BASE_MOVE_SPD * mult_move_spd) * mult_move_spd_temp


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("item_equipped", equip_item)
	SignalBus.augment_confirm.connect(_add_augment)
	SignalBus.augment_keep.connect(_keep_perm_augment)

func get_all_augments() -> Array[Augment]:
	var total_augments : Array[Augment] = []
	total_augments.append_array(temp_augments)
	total_augments.append_array(perm_augments)
	return total_augments

func _add_augment(_augment : Augment) -> void:
	print("addign agument: ", _augment.name)
	temp_augments.append(_augment)
	_connect_augment_effects(_augment)
	recalculate()
 
func _keep_perm_augment(_augment : Augment) -> void:
	# go through temp augments and disconnect 
	for temp_aug in temp_augments:
		_disconnect_augment_effects(temp_aug)
	temp_augments.clear()
	
	if _augment != null:
		perm_augments.append(_augment)
		_connect_augment_effects(_augment)
	recalculate()

func equip_item(item_equipped : Item):
	equipped_items[item_equipped.type] = item_equipped
	recalculate()

func recalculate() -> void:
	#_reset_bonuses()
	var stats_calc : Dictionary = _calculate_stats(equipped_items, get_all_augments())
	bonus_hp = stats_calc["bonus_hp"]
	bonus_atk = stats_calc["bonus_atk"]
	bonus_crit_rate = stats_calc["bonus_crit_rate"]
	bonus_crit_dmg = stats_calc["bonus_crit_dmg"]
	mult_hp = stats_calc["mult_hp"]
	mult_atk = stats_calc["mult_atk"]
	mult_atk_spd = stats_calc["mult_atk_spd"]
	mult_move_spd = stats_calc["mult_move_spd"]
	
	SignalBus.stats_updated.emit()
	
	#print("--- recalculate ---")
	#print("HP:        ", hp)
	#print("ATK:       ", atk)
	#print("ATK_SPD:   ", atk_spd)
	#print("CRIT_RATE: ", crit_rate)
	#print("CRIT_DMG:  ", crit_dmg)
	#print("MOVE_SPD:  ", move_speed)

func _calculate_stats(items : Dictionary, augs : Array) -> Dictionary:
	var stats_calc : Dictionary = {
		"bonus_hp" : 0.0,
		"bonus_atk" : 0.0,
		"bonus_crit_rate" : 0.0,
		"bonus_crit_dmg" : 0.0,
		"mult_hp" : 1.0,
		"mult_atk" : 1.0,
		"mult_atk_spd" : 1.0,
		"mult_move_spd" : 1.0,
	}
		# LOOP THROUGH EQUIPPED ITEMS AND RECALCULATE NEW BONUSES
	for item: Item in items.values():
		if item == null:
			continue
		for stat: Dictionary in item.stats:
			match stat.stat_attribute:
				Item.StatAttribute.HP : stats_calc["bonus_hp"] += stat.value
				Item.StatAttribute.ATK : stats_calc["bonus_atk"] += stat.value
				Item.StatAttribute.CRIT_RATE : stats_calc["bonus_crit_rate"] += stat.value
				Item.StatAttribute.CRIT_DMG : stats_calc["bonus_crit_dmg"] += stat.value
				Item.StatAttribute.ATK_SPD : stats_calc["mult_atk_spd"] += (stat.value / 100.0)
				Item.StatAttribute.MOVE_SPD : stats_calc["mult_move_spd"] += (stat.value / 100.0)
	
	# LOOP THROUGH AUGMENTS AND APPLY AT STATS
	for augment in augs:
		var stat_fields = augment.augment_stats
		for stat_field in stat_fields:
			var pct : float = stat_field.stat_value / 100.0
			match stat_field.stat_attribute:
				Item.StatAttribute.HP : stats_calc["mult_hp"] += pct
				Item.StatAttribute.ATK : stats_calc["mult_atk"] += pct
				Item.StatAttribute.CRIT_RATE : stats_calc["bonus_crit_rate"] += stat_field.stat_value
				Item.StatAttribute.CRIT_DMG : stats_calc["bonus_crit_dmg"] += stat_field.stat_value
				Item.StatAttribute.ATK_SPD : stats_calc["mult_atk_spd"] += pct
				Item.StatAttribute.MOVE_SPD : stats_calc["mult_move_spd"] += pct
	return stats_calc

func _reset_bonuses() -> void:
	bonus_hp = 0
	bonus_atk  = 0
	bonus_crit_rate = 0.0
	bonus_crit_dmg = 0.0 


func _connect_augment_effects(_new_augment : Augment) -> void:
	#for augment in augments:
	var augment_effect : AugmentEffect = _new_augment.augment_effect
	match augment_effect.effect_type:
		AugmentEffect.EffectType.ON_KILL : on_kill.connect(augment_effect.apply_effect)
		AugmentEffect.EffectType.ON_HIT : on_hit.connect(augment_effect.apply_effect)
		AugmentEffect.EffectType.ON_DAMAGED : on_damaged.connect(augment_effect.apply_effect)
		AugmentEffect.EffectType.PASSIVE : augment_effect.apply_passive()

func _disconnect_augment_effects(_augment : Augment) -> void:
	#for augment in augments:
	var augment_effect : AugmentEffect = _augment.augment_effect
	match augment_effect.effect_type:
		AugmentEffect.EffectType.ON_KILL : on_kill.disconnect(augment_effect.apply_effect)
		AugmentEffect.EffectType.ON_HIT : on_hit.disconnect(augment_effect.apply_effect)
		AugmentEffect.EffectType.ON_DAMAGED : on_damaged.disconnect(augment_effect.apply_effect)
		AugmentEffect.EffectType.PASSIVE : augment_effect.reset_apply()

func preview_equipment(new_item : Item) -> Dictionary:
	var current = {
		 Item.StatAttribute.HP :  hp,
		 Item.StatAttribute.ATK  :  atk,
		 Item.StatAttribute.ATK_SPD : atk_spd,
		 Item.StatAttribute.CRIT_RATE : crit_rate,
		 Item.StatAttribute.CRIT_DMG :  crit_dmg,
		 Item.StatAttribute.MOVE_SPD : move_speed,
	}
	
	var swapped_equip : Dictionary = equipped_items.duplicate()
	swapped_equip[new_item.type] = new_item
	var accum : Dictionary = _calculate_stats(swapped_equip, get_all_augments())
	
	var preview : Dictionary = {
		Item.StatAttribute.HP :  (BASE_HP + accum["bonus_hp"]) * accum["mult_hp"],
		Item.StatAttribute.ATK  :  (BASE_ATK + accum["bonus_atk"]) * accum["mult_atk"],
		Item.StatAttribute.ATK_SPD : BASE_ATK_SPD * accum["mult_atk_spd"],
		Item.StatAttribute.CRIT_RATE : BASE_CRIT_RATE + accum["bonus_crit_rate"],
		Item.StatAttribute.CRIT_DMG :  BASE_CRIT_DMG + accum["bonus_crit_dmg"],
		Item.StatAttribute.MOVE_SPD : BASE_MOVE_SPD * accum["mult_move_spd"],
	}
	
	var res : Dictionary = {}
	for stat_attrib in preview:
		res[stat_attrib] = {
			"preview" : snappedf(preview[stat_attrib], .01),
			"diff" : snappedf(preview[stat_attrib], .01) - snappedf(current[stat_attrib], .01)
		}
	
	return res

func handle_out_damage(target : Enemy) -> float: 
	var random_rate : float = (randf() * 100.0)
	var final_dmg : float
	if random_rate < crit_rate:
		final_dmg = (atk * (crit_dmg / 100.0))
	else:
		final_dmg = atk
	
	var info : Dictionary = {"enemy" : target, "damage_done" : final_dmg}
	on_hit.emit(info)
	return final_dmg

func set_temp_move_mult(move_mult : float, duration : float) -> void:
	mult_move_spd_temp = move_mult
	SignalBus.stats_updated.emit()

	if duration <= 0: 
		return
	
	await get_tree().create_timer(duration).timeout
	mult_move_spd_temp = 1.0
	SignalBus.stats_updated.emit()

func try_consume_celspike() -> bool:
	if celspike_charges <= 0:
		return false
	celspike_charges -= 1
	celspike_charges_changed.emit(celspike_charges, MAX_CELSPIKE_CHARGE)
	start_celspime_recharge()
	return true

func start_celspime_recharge() -> void:
	if celspike_recharging:
		return
	celspike_recharging = true
	while celspike_charges < MAX_CELSPIKE_CHARGE:
		await get_tree().create_timer(CELSPIKE_RECHARGE_TIME * charged_celspike_cd_mult).timeout
		celspike_charges += 1
		celspike_charges_changed.emit(celspike_charges, MAX_CELSPIKE_CHARGE)
	celspike_recharging = false

func clear_temp_augments() -> void:
	for temp_aug in temp_augments:
		_disconnect_augment_effects(temp_aug)
	temp_augments.clear()
	recalculate()
