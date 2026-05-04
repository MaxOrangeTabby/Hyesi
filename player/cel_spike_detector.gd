extends Area2D

var detect_celspike : bool = false
var cel_spike : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func in_range_celspike() -> bool:
	return detect_celspike

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("cel_spike_group"):
		cel_spike = body
		detect_celspike = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("cel_spike_group"):
		cel_spike = null
		detect_celspike = false

func get_cel_spike() -> CharacterBody2D:
	return cel_spike
