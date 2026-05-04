extends CharacterBody2D

static var active_spike : CharacterBody2D = null

@export var speed : float = 4500.0
@export var acceleration : float = 6500.0
@export var cel_spike_collider : CollisionShape2D
@export var terrain_collider : CollisionShape2D

@export var can_move : bool = true
@export var init_pos : Vector2 = Vector2(0.0, 0.0)
@export var init_dir : Vector2 = Vector2(1.0, 0.0)
@export var anim_sprite : AnimatedSprite2D

@export var celspike_mark : Node2D

# SET BY THE PARENT - IF FIRE FROM FOCUS MODE OR NOT
var is_focused : bool = false

func _ready() -> void:
	if active_spike and is_instance_valid(active_spike):
		active_spike.queue_free()
	active_spike = self
	
	#global_position = init_pos
	rotation = init_dir.angle()
	cel_spike_collider.disabled = true
	
	if sign(init_dir.x) >= 0:
		scale.y *= 1.0
	else:
		scale.y *= -1.0
		
	if celspike_mark:
		celspike_mark.global_rotation = 0
		celspike_mark.scale.x *= sign(scale.x)
		celspike_mark.scale.y *= sign(scale.y)

func _process(delta: float) -> void:
	if can_move:
		#velocity = velocity.move_toward(speed * init_dir, acceleration * delta)
		velocity = speed * init_dir
		var real_velocity : Vector2 = velocity
		var velocity_scale : float = 1.0 / Engine.time_scale
		
		velocity *= velocity_scale
		move_and_slide()
		velocity = real_velocity
