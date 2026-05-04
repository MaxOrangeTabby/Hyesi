
extends Node2D

@onready var raycast : RayCast2D = %RayCast2D
@onready var line2d : Line2D  = %Line2D
@onready var laser_particles : GPUParticles2D = %LaserParticles


@export var line_color : Color = Color(0.0, 2.369, 0.584)
@export var line_width : float = 30
@export var start_distance := 0.0
@export var enemy_ref : Enemy

@export var damage : float = 1.0
@export var knockback : float = 800.0

var _beam_sfx : AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	raycast.is_casting = false
	laser_particles.emitting = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_laser() -> void:
	_beam_sfx = SFX.play_2d(SFXType.TYPES.BEAM_BLAST, self)
	#print("laser fire — attack_stuff.scale.x = ", get_parent().scale.x)
	
	raycast.set_color(line_color)
	raycast.is_casting = true

func stop_laser() -> void:
	if is_instance_valid(_beam_sfx) and _beam_sfx.playing:
		_beam_sfx.stop()
	raycast.is_casting = false
