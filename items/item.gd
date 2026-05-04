class_name Item
extends Resource

enum Rarity { COMMON , RARE, EPIC, LEGENDARY }
enum ItemType {WEAPON, CIRCLET, PENDANT}
enum StatAttribute {HP,ATK, ATK_SPD, CRIT_RATE, CRIT_DMG, MOVE_SPD}


@export var name : String

## {WEAPON, CIRCLET, PENDANT}
@export var type : ItemType
@export var texture : Texture2D
@export var rarity : Rarity

## {name : speed, value : 100}
@export var stats : Array[Dictionary] 


# Format: {stat_name : [min, max]}
#@export var stat_ranges : Dictionary[String, float]

# Fromat: {name : icon}
#@export var name_icon_map : Dictionary[String, Texture2D]

func rarity_name() -> String:
	return Rarity.keys()[rarity]
