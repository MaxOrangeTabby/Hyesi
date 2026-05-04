extends Area2D

@export var spring_strength : float = -2900

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.activateSpring(Vector2(0, spring_strength))
