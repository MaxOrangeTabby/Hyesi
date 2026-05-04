class_name ItemDB
extends Resource

# ITEM TO TEXTURE
@export var item_texture_map : Dictionary[String, Texture2D]

# LIST OF THE POSSIBLE ITEMS 
@export var item_list : Array[Item]
@export var rarity_texture_map : Dictionary[Item.Rarity, Texture2D]
@export var rarity_color_map : Dictionary[Item.Rarity, Color]
