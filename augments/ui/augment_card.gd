extends Control

@onready var augment_tex : TextureRect = %AugmentTex
@onready var augment_name : Label = %AugmentName
@onready var augment_desc : Label = %AugmentDesc

var augment : Augment

func populate(_augment : Augment) -> void: 
	augment = _augment
	
	augment_name.text = _augment.name
	augment_tex.texture = _augment.texture
	augment_desc.text = _augment.augment_effect.get_desc()


func _on_button_pressed() -> void:
	print("PRESSING AUGMENT")
	SignalBus.augment_selected.emit(augment)
