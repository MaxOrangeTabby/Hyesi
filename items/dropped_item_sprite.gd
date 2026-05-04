extends AnimatedSprite2D


func _ready() -> void:
	var random_color : Color = (Color.from_hsv(randf(), 1.0, 1.0, 1.25)) * 1.25
	modulate = random_color
