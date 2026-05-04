extends CanvasLayer

@export var celspike_textures : Array[TextureRect]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerKit.celspike_charges_changed.connect(charges_changed)
	update_ui(PlayerKit.celspike_charges, PlayerKit.MAX_CELSPIKE_CHARGE)

func charges_changed(current_charge : int, max_charge : int) -> void:
	update_ui(current_charge, max_charge)

func update_ui(current_charge : int, max_charge : int) -> void:
	for cs_tex in celspike_textures.size():
		if cs_tex < current_charge:
			celspike_textures[cs_tex].modulate = Color.WHITE
		else:
			celspike_textures[cs_tex].modulate = Color(0.998, 0.998, 1.25, 0.196)

		
