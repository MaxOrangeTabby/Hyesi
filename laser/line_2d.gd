
extends Line2D

@export var laser_beam : Node2D
@export var raycast : RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	width = laser_beam.line_width


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
