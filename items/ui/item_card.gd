class_name ItemCard
extends PanelContainer


@onready var item_name_label : Label = %ItemNameLabel
@onready var item_rarity_label : Label = %ItemRarityLabel
@onready var item_icon : TextureRect = %ItemIcon
@onready var stats_desc : VBoxContainer = %StatsDesc
@onready var item_tier_panel : PanelContainer = %ItemTier

@export var item_db : ItemDB

const StatRow = preload("uid://bq1c55m62p2h")
var current_item : Item

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass

#@export var name : String
#@export var type : String
#@export var texture : Texture2D
#export var rarity : Rarity
#@export var stats : Array[Dictionary] 

func create_card(item : Item) -> void:
	#print("item name in card: ", item.name)
	current_item = item
	
	if item_name_label:
		item_name_label.text = item.name
	if item_rarity_label:
		item_rarity_label.text = item.rarity_name()
	if item_icon:
		item_icon.texture = item.texture
	
	item_tier_panel.modulate = Color(item_db.rarity_color_map[item.rarity])
	
	# clear out the old stats
	for child_stat in stats_desc.get_children():
		stats_desc.remove_child(child_stat)
		child_stat.queue_free()
	
	
	if item.stats:
		for stat in item.stats:
			var stat_name : String = stat["name"]
			var stat_value : float = snapped(stat["value"], .01)
			var stat_type : String = stat["stat_type"]
			var stats_row = StatRow.instantiate()
			stats_desc.add_child(stats_row)
			stats_row.create_stats_row(stat_name, stat_value, stat_type)
		


func _on_equip_button_pressed() -> void:
	SFX.play_ui(SFXType.TYPES.CONFIRM_INVENTORY, self)

	SignalBus.emit_signal("item_equipped", current_item)
