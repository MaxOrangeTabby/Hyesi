extends Area2D

@export var dialogue_string : String


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.start_dialogue(dialogue_string)
