extends ProgressBar

@onready var timer : Timer = %DamageBarTimer
@onready var damage_bar : ProgressBar = %DamageBar
@onready var laser_particles : GPUParticles2D =  %LaserParticles

@export var boss_name_label : Label 

#var boss : CharacterBody2D

var current_enemy : Enemy
var hp : float = 0 : set = _set_health

func _ready() -> void:
	laser_particles.modulate = Color(3.003, 0.776, 0.56)
	damage_bar.modulate = Color(3.488, 0.424, 0.0)
	
	
	visible = false
	SignalBus.enemy_damaged.connect(_enemy_damaged)


func _set_health(new_hp : float) -> void:
	update_particle_pos()
	if laser_particles:
		laser_particles.restart()
	
	var prev_hp = hp
	hp = min(max_value, new_hp)
	
	var tween = create_tween()
	tween.tween_property(self, "value", hp, .15)
	tween.set_ease(Tween.EASE_OUT)
	
	#value = hp
	
	if hp <= 0:
		print("IN GAME UI: OUT OF HP -> PUT SIGNAL HERE")
	if hp < prev_hp:
		timer.start()
	else:
		damage_bar.value = hp

func init_health(_hp):
	max_value = _hp
	value = _hp
	damage_bar.max_value = _hp
	damage_bar.value = _hp
	hp = _hp

func _on_damage_bar_timer_timeout() -> void:
	#damage_bar.value = hp
	
	var tween = create_tween()
	tween.tween_property(damage_bar, "modulate", Color(1.353, 0.0, 0.0, 1.0), .05)
	tween.tween_property(damage_bar, "modulate", Color(0.176, 0.906, 0.835, 1.0), .05)

	tween.tween_property(damage_bar, "value", hp, .35)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)

func update_particle_pos() -> void:
	var value_ratio = value / max_value
	if laser_particles:
		laser_particles.position.x = size.x * value_ratio
	else:
		print("in hp bar: laser part does not exists")

func _enemy_damaged(enemy : Enemy) -> void:
	if enemy != current_enemy:
		_switch_enemy(enemy)
	_set_health(enemy.hp)

func _switch_enemy(enemy : Enemy) -> void:
	if current_enemy and current_enemy.on_died.is_connected(_enemy_died):
		current_enemy.on_died.disconnect(_enemy_died)
	current_enemy = enemy
	init_health(enemy.max_hp)
	
	visible = true
	enemy.on_died.connect(_enemy_died)
	if boss_name_label:
		boss_name_label.text = current_enemy.enemy_name

func _enemy_died() -> void:
	current_enemy = null
	visible = false
