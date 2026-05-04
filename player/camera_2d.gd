extends Camera2D

#@export var shake_strengh : float = 6
@export var shake_falloff : float = 8
@onready var pcam_host : PhantomCameraHost = %PhantomCameraHost

var active_pcam : PhantomCamera2D

var shake_power_left : float = 0
var cont_shake : bool = false
var cam_tween : Tween
var base_zoom : Vector2

func _ready() -> void:
	if pcam_host:
		active_pcam = pcam_host.get_active_pcam()
		if active_pcam:
			base_zoom = active_pcam.get_zoom()
	
	SignalBus.trigger_camera_shake.connect(shake_camera)
	SignalBus.trigger_cont_camera_shake.connect(start_cont_shake)
	SignalBus.stop_cont_camera_shake.connect(stop_cont_shake)
	SignalBus.punch_camera.connect(punch_camera)

func shake_camera(shake_strengh_var : float) -> void:
	shake_power_left = shake_strengh_var
	set_process(true)

func _process(delta: float) -> void:
	if shake_power_left > 0: 
		if not cont_shake:
			shake_power_left = lerp(shake_power_left, 0.0, shake_falloff * delta)
		var shake_range = randf_range(-shake_power_left, shake_power_left)
		var shake_range2 = randf_range(-shake_power_left, shake_power_left)
		offset = Vector2(shake_range, shake_range2)
	else:
		set_process(false)

func shake_camera_var(shake_strengh_var : float) -> void:
	shake_power_left = shake_strengh_var
	set_process(true)

func redden_camera() -> void:
	pass

# for a continous shake
func start_cont_shake(strengh : float):
	cont_shake = true
	shake_power_left =  strengh
	set_process(true)
	get_tree().create_timer(8).timeout.connect(stop_cont_shake)

func stop_cont_shake():
	cont_shake = false
	offset = Vector2.ZERO
	set_process(false)

func punch_camera(zoom_scale : float, offset_strength : float) -> void:
	if not active_pcam:
		return
	if cam_tween:
		cam_tween.kill()
	active_pcam.set_zoom(base_zoom)
	
	var new_zoom : Vector2 = base_zoom * zoom_scale
	var shake_range = randf_range(-offset_strength, offset_strength)
	var shake_range2 = randf_range(-offset_strength, offset_strength)

	active_pcam.set_zoom(new_zoom)
	#offset = Vector2(shake_range, shake_range2)

	cam_tween = create_tween()
	cam_tween.set_parallel(true)
	cam_tween.set_trans(Tween.TRANS_CUBIC)
	cam_tween.set_ease(Tween.EASE_OUT)
	cam_tween.tween_property(active_pcam, "zoom", base_zoom, .65)
	#cam_tween.tween_property(self, "offset", Vector2.ZERO, .45)

func _on_phantom_camera_host_pcam_became_active(pcam: Node) -> void:
	active_pcam = pcam
	base_zoom = active_pcam.get_zoom()
