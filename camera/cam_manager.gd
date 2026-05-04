extends Node

@export var zones : Array[Area2D]
@export var pcams : Array[PhantomCamera2D]
@export var default_pcam : PhantomCamera2D

var _stack : Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in zones.size():
		var idx : int = i
		zones[i].body_entered.connect(func(b) : _on_enter(b, idx))
		zones[i].body_exited.connect(func(b) : _on_exit(b, idx))
	_apply()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_enter(body, idx) -> void:
	if body.is_in_group("player_group"):
		_stack.push_back(idx)
		_apply()

func _on_exit(body, idx) -> void:
	if body.is_in_group("player_group"):
		_stack.erase(idx)
		_apply()

func _apply() -> void:
	for p in pcams: 
		p.priority = 0
	default_pcam.priority = 1
	if _stack.size() > 0:
		pcams[_stack.back()].priority = 10
	print("camera stack: ", _stack, " | active: ", _stack.back() if _stack.size() > 0 else "default")
