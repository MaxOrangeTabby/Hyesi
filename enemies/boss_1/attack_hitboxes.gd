extends Node2D

@export var stomp_dmg : int = 40
@export var dash_dmg : int = 20
@export var parent_node : Enemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_stomp_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.take_damage(stomp_dmg, parent_node, global_position, 4500)


func _on_dash_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.take_damage(dash_dmg,parent_node,global_position, 5500)
