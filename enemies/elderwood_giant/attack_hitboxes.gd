extends Node2D

@export var punch_dmg : float = 40
@export var smash_dmg : float = 57
@export var parent_node : Enemy




func _on_punch_hb_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.take_damage(punch_dmg, parent_node, global_position, 1000)


func _on_smash_hb_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.take_damage(smash_dmg, parent_node, global_position, 3000)
