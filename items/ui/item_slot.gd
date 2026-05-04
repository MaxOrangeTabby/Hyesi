class_name ItemSlot
extends Control

@onready var border_rect : TextureRect = %BorderTexture
@onready var item_rect: TextureRect = %ItemTexture
@onready var rarity_item_border : PanelContainer = %ItemRarityBorder
@onready var item_db : ItemDB = preload("uid://bbeu8j0kur5ob")

var saved_item : Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_item_slot(item : Item, item_name : String, item_rarity : Item.Rarity):
	saved_item = item
	item_rect.texture = item.texture
	#print("item rarirty: ", item_rarity)
	border_rect.texture = item_db.rarity_texture_map[item_rarity]
	
	var style_box : StyleBoxFlat = rarity_item_border.get_theme_stylebox("panel").duplicate()
	style_box.border_color = item_db.rarity_color_map[item_rarity]
	rarity_item_border.add_theme_stylebox_override("panel", style_box)
	

func _on_button_pressed() -> void:
	SignalBus.item_slot_clicked.emit(saved_item)
