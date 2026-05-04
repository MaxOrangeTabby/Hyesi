extends Area2D

@export var spire_dmg : int = 20
@export var parent_node : Spire


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.take_damage(spire_dmg, parent_node.source_enemy, global_position, 400)
		
