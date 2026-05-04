extends Label

@export var agent : CharacterBody2D 

func _process(_delta: float) -> void:
	pass
	text = str(agent.hp)
