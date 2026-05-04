extends Node

const augment_db : AugmentDB = preload("uid://cgksc287sxaja")
const item_db : ItemDB = preload("uid://bbeu8j0kur5ob")
var item_texture_map : Dictionary[String, Texture2D]

const RARITIES = [
	{"name" : Item.Rarity.COMMON, "weight" : 50.0, "stat_range" : [1,1], "stat_mult" : [0, .25]},
	{"name" : Item.Rarity.RARE, "weight" : 24.0, "stat_range" : [1,2], "stat_mult" : [.25, .5]},
	{"name" : Item.Rarity.EPIC, "weight" : 16.0, "stat_range" : [2,3], "stat_mult" : [.5, .75]},
	{"name" : Item.Rarity.LEGENDARY, "weight" : 10.0, "stat_range" : [2,3], "stat_mult" : [.75, 1]}
]

const STAT_POOL = [
	{"name" : "Attack", "stat_range" : [5, 20], "stat_type" : "flat", "stat_attribute" : Item.StatAttribute.ATK},
	{"name" : "Crit Rate", "stat_range" : [5, 25], "stat_type" : "percentage", "stat_attribute" : Item.StatAttribute.CRIT_RATE},
	{"name" : "Crit Damage", "stat_range" : [1, 20], "stat_type" : "percentage", "stat_attribute" : Item.StatAttribute.CRIT_DMG},
	{"name" : "Attack Speed", "stat_range" : [.1, .65], "stat_type" : "percentage", "stat_attribute" : Item.StatAttribute.ATK_SPD},
	{"name" : "HP", "stat_range" : [20, 80], "stat_type" : "flat", "stat_attribute" : Item.StatAttribute.HP},
	{"name" : "Speed Boost", "stat_range" : [5, 25], "stat_type" : "percentage", "stat_attribute" : Item.StatAttribute.MOVE_SPD},

 
]

func _ready() -> void:
	pass
	#item_texture_map = item_db.item_texture_map
	

func generate() -> Item:
	var item = Item.new()
	
	# roll rarity
	var rarity_data = roll_rarity()
	item.rarity = rarity_data["name"]
	
	# get the state count
	var stat_count = randi_range(rarity_data.stat_range[0], rarity_data.stat_range[1])
	
	# get the random item name and icon
	var random_item : Item = item_db.item_list.pick_random()
	
	#var item_keys : Array[String] = item_db.item_texture_map.keys()
	#var random_key : String = item_keys[randi() % item_keys.size()]
	var item_name : String = random_item.name
	var item_texture : Texture2D = random_item.texture
	var item_type : Item.ItemType = random_item.type

	
	item.name = item_name
	item.texture = item_texture
	item.type = item_type
	
	# get randomized stats
	# shuffled pool 
	var shuffled_pool = (STAT_POOL.duplicate())
	shuffled_pool.shuffle()
	
	for i in stat_count:
		if i < shuffled_pool.size():
			var stat = shuffled_pool[i]
			var stat_min : float = float(stat.stat_range[0])
			var stat_max : float = float(stat.stat_range[1])
			
			var low_bound = lerp(stat_min, stat_max, rarity_data["stat_mult"][0])
			var high_bound = lerp(stat_min, stat_max, rarity_data["stat_mult"][1])
			var stat_val : float = randf_range(low_bound, high_bound)
			
			if(stat.stat_type == "percentage"):
				stat_val = snappedf(stat_val, .1)
			else: 
				stat_val = roundi(stat_val)
			item.stats.append({
				"name" : stat.name, "value" : stat_val,
				"stat_type" : stat.stat_type, "stat_attribute" : stat.stat_attribute
			})
	
	return item

func roll_rarity() -> Dictionary:
	var total : int = 100
	var sub_total : int = randi() % total
	
	for r in RARITIES:
		sub_total -= r.weight
		if(sub_total <= 0):
			return r
	return RARITIES[0]

func get_random_augments() -> Array[Augment]: 
	var shuffled_pool : Array[Augment] = augment_db.augment_list.duplicate()
	shuffled_pool.shuffle()
	shuffled_pool = shuffled_pool.filter(check_unique_augment)
	
	return shuffled_pool.slice(0, min(3, shuffled_pool.size()))

func check_unique_augment(_augment : Augment) -> bool:
	if PlayerKit.perm_augments.has(_augment):
		return false
	if PlayerKit.temp_augments.has(_augment):
		return false
	return true
