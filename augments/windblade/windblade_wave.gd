extends Area2D

@export var speed : float = 6000.0
@export var lifetime : float = 1.5

var direction : Vector2 = Vector2.RIGHT

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.process_damage(PlayerKit.atk * .45, 1, 0)
		queue_free()
