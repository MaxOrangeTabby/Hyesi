extends Node

var last_location : Vector2 = Vector2(-5800, 1150)
var has_checkpoint : bool = false


func set_checkpoint(_pos : Vector2) -> void:
	last_location = _pos
	has_checkpoint = true

func get_respawn_pos() -> Vector2: 
	if has_checkpoint: 
		return last_location
	else:
		return Vector2.ZERO
