
extends RayCast2D

@export var cast_speed : float  = 7000.0
@export var max_length : float = 700.0
@export var growth_time : float = .2
@export var color := Color.WHITE: set = set_color
@export var laser_beam : Node2D
@export var is_casting := false: set = set_is_casting



@onready var laser_particles: GPUParticles2D = %LaserParticles

#@onready var collision_particles: GPUParticles2D = %CollisionParticles
#@onready var beam_particles: GPUParticles2D = %BeamParticles2D
@onready var line_2d : Line2D = %Line2D
@onready var line_2d_width = %Line2D.width



var tween : Tween = null
var start_distance : float

func _ready():
	#set_is_casting(is_casting)
	start_distance = laser_beam.start_distance
	line_2d.points[0] = Vector2.RIGHT * start_distance
	line_2d.points[1] = Vector2.ZERO
	line_2d.visible = false
	laser_particles.position = line_2d.points[0] + Vector2(0, -20)
	

	if not Engine.is_editor_hint():
			set_physics_process(false)
func _physics_process(delta: float) -> void:
	target_position = target_position.move_toward(Vector2.RIGHT * max_length, cast_speed * delta)
	
	var lazer_end_position = target_position
	force_raycast_update()
	if is_colliding():
		var obj = get_collider()
		if obj.is_in_group("player_group"):
			obj.take_damage(laser_beam.damage, laser_beam.enemy_ref, global_position, laser_beam.knockback)
		lazer_end_position = to_local(get_collision_point())
	
	if lazer_end_position.x < start_distance:
		lazer_end_position.x = start_distance
	line_2d.points[1] =  lazer_end_position

	var lazer_start_position = line_2d.points[0] + Vector2(0, -20)


func set_is_casting(new_val : bool) -> void:
	if is_casting == new_val:
		return
	is_casting = new_val
	set_physics_process(is_casting)

	laser_particles.emitting = is_casting

	if is_casting and line_2d:
		var laser_start := Vector2.RIGHT * start_distance
		line_2d.points[0] = laser_start
		line_2d.points[1] = laser_start
		target_position = laser_start
		laser_particles.position = laser_start  + Vector2(0, -20)
		appear()
	elif line_2d:
		target_position = Vector2.ZERO
		#collision_particles.emitting = false
		disappear()

func appear() -> void:
	#print("APPER, LINE WIDTH: ", line_2d_width)
	line_2d.visible = true
	
	#print("APPER, LINE WIDTH: ", line_2d_width)

	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(line_2d, "width", line_2d_width, growth_time * 2.0).from(0.0)
	
func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", 0.0, growth_time).from_current()
	tween.tween_callback(line_2d.hide)
	#collision_particles.emitting = false

func set_color(new_color: Color) -> void:
	color = new_color

	if line_2d == null:
		return

	line_2d.modulate = new_color
	#laser_particles.modulate = new_color
	#collision_particles.modulate = new_color
	#beam_particles.modulate = new_color
