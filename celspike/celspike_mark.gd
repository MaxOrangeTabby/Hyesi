extends Node2D

@export var celspike_sprite : Sprite2D
@export var mouse_sprite : Sprite2D

var move_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_rotation = 0
	visible = false


func show_sprites() -> void:
	if visible: return
	visible = true
	
	move_tween = create_tween()
	move_tween.set_loops()
	move_tween.tween_property(mouse_sprite, "position:y", mouse_sprite.position.y - 20, .3)
	move_tween.tween_property(mouse_sprite, "position:y", mouse_sprite.position.y + 20, .3)

func hide_sprites() -> void:
	if move_tween: 
		move_tween.kill()
	if not visible:
		return
	visible = false
