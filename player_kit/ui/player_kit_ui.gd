extends Control



@onready var weapon_texture : TextureRect = %WeaponTexture
@onready var circlet_texture : TextureRect = %CircletTexture
@onready var pendant_texture : TextureRect = %PendantTexture

@onready var hp_label : Label = %HPVal
@onready var atk_label : Label = %ATKVal
@onready var atk_spd_label : Label = %ATKSPDVal
@onready var crit_rate_label : Label = %CritRateVal
@onready var crit_dmg_label : Label = %CritDMGVal
@onready var move_spd_label : Label = %MoveSPDVal

@export var up_texture : Texture2D
@export var down_texture : Texture2D
@export var neutral_texture : Texture2D

@export var stat_difftexture_map : Dictionary[Item.StatAttribute, TextureRect]
@export var stat_difflabel_map : Dictionary[Item.StatAttribute, Label]

#@export var augments : Array[Augment]

var prev_equipped_item : Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("item_equipped", equip_item)
	SignalBus.connect("stats_updated", update_stats_ui)
	SignalBus.connect("item_slot_clicked", preview_stats)
	update_stats_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func equip_item(item : Item):
	prev_equipped_item = item
	
	if item:
		var item_type = item.type
		if item_type == Item.ItemType.WEAPON:
			weapon_texture.texture = item.texture
		if item_type == Item.ItemType.CIRCLET:
			circlet_texture.texture = item.texture
		if item_type == Item.ItemType.PENDANT:
			pendant_texture.texture = item.texture
	else:
		print("INSIDE PLAYERKIT SCENE: ITEM NOT VALID")

func update_stats_ui() -> void:
	hp_label.text  = str(PlayerKit.hp)
	atk_label.text  = str(PlayerKit.atk)
	atk_spd_label.text  = "%+.1f" % ((PlayerKit.atk_spd - 1.0) * 100.0) + "%"
	crit_rate_label.text  = "%.0f" % PlayerKit.crit_rate + "%"
	crit_dmg_label.text  = "%.0f" % PlayerKit.crit_dmg + "%"
	move_spd_label.text  = "+%.0f" %  ((PlayerKit.move_speed - 1.0) * 100.0)+ "%"
	
	if prev_equipped_item:
		#print("updating ui")
		preview_stats(prev_equipped_item)

func preview_stats(item_clicked : Item) -> void:
	#print("PREVIEWING STATS: ", PlayerKit.preview_equipment(item_clicked))
	var preview : Dictionary = PlayerKit.preview_equipment(item_clicked)
	
# preview = {"preview" = {}, "diff" = {}}
	for stat_attrib in preview.keys():
		if(preview[stat_attrib].diff == 0.0):
			stat_difftexture_map[stat_attrib].texture = neutral_texture
			stat_difflabel_map[stat_attrib].text = ""
		elif(signf(preview[stat_attrib].diff) >= 1):
			stat_difftexture_map[stat_attrib].texture = up_texture
			stat_difflabel_map[stat_attrib].text = "→" + format_stat(stat_attrib, preview[stat_attrib].preview)
			stat_difflabel_map[stat_attrib].modulate = Color("#5dcaa5")

		elif(signf(preview[stat_attrib].diff) <= -1):
			stat_difftexture_map[stat_attrib].texture = down_texture
			stat_difflabel_map[stat_attrib].text = "→" + format_stat(stat_attrib, preview[stat_attrib].preview)
			stat_difflabel_map[stat_attrib].modulate = Color("#d34746")

func format_stat(attrib : Item.StatAttribute, value : float) -> String:
	match attrib:
		Item.StatAttribute.HP, Item.StatAttribute.ATK:
			return "%d" % value
		Item.StatAttribute.CRIT_RATE, Item.StatAttribute.CRIT_DMG:
			return "%.0f" % value + "%"
		Item.StatAttribute.ATK_SPD, Item.StatAttribute.MOVE_SPD:
			return "+%.0f" %  ((value - 1.0) * 100.0)+ "%"
	return str(value)
