extends CanvasLayer

@onready var flash : ColorRect = %DamageFlash
@export var peak_intensity : float = .65
@export var flash_duration : float = .35
@export var hp_max_intensity : float = .1

var flash_tween : Tween
var base_intensity : float = 0.0

func _ready() -> void:
	SignalBus.player_damaged.connect(_handle_player_damaged)
	SignalBus.player_hp_changed.connect(_handle_hp_change)

func _handle_player_damaged() -> void:
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()
	flash.material.set_shader_parameter("intensity", peak_intensity)
	flash_tween = create_tween()
	flash_tween.set_ease(Tween.EASE_OUT)
	flash_tween.set_trans(Tween.TRANS_CUBIC)
	flash_tween.tween_property(flash.material, "shader_parameter/intensity", base_intensity, flash_duration)

func _handle_hp_change(current_hp : float, max_hp : float) -> void:
	if max_hp <= 0:
		base_intensity = 0.0
	else:
		var ratio : float =  1.0 - clampf(float(current_hp) / float(max_hp), 0.0, 1.0)
		if ratio <= .5:
			ratio = 0
		
		#print("ratiO: ", ratio)
		base_intensity = ratio * hp_max_intensity
	if flash_tween and (not flash_tween.is_running()):
		flash.material.set_shader_parameter("intensity", base_intensity)
