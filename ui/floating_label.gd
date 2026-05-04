extends Label

@export var float_distance : float = 100

func _ready() -> void:
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y - float_distance, 1.5)
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	
	tween.finished.connect(queue_free)
