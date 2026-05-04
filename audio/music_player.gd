extends AudioStreamPlayer


const TRACKS : Array[AudioStream] = [
	preload("uid://dye4m6vm3nvsa"),
	preload("uid://ctmn1bfulg8ys")
]

var _idx : int = 0
func _ready() -> void:
	finished.connect(_on_finished)
	stream = TRACKS[0]
	play()

func _on_finished() -> void:
	_idx = (_idx  + 1) % TRACKS.size()
	stream = TRACKS[_idx]
	play()
