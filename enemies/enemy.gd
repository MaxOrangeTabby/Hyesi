class_name Enemy
extends CharacterBody2D

const DROPPED_ITEM_SCENE : PackedScene = preload("uid://ck1m7pdonnj1c")

@export var enemy_name : String
@export var max_hp : float
@export var hp : float 
@export var def : float
@export var dmg_reduction : float
@export var invincible : bool

# cut down regen rate when in combat
@export var regen_enabled : bool
@export var regen_rate : float
@export var attack_dmg : float

@export var loot_spawn_count : int

@export var celspike_mark : Node2D

var dead : bool = false

signal on_died

func process_damage(incoming_dmg : float, zoom_scale : float, offset_strength : float, dir : Vector2 = Vector2(1,1)) -> void: 
	var final_dmg : float = max(0.0, (incoming_dmg * (1.0 - dmg_reduction)) - def)
	hp -= final_dmg
	SignalBus.enemy_damaged.emit(self)
	SFX.play_2d(SFXType.TYPES.ENEMY_HIT, self)
	SignalBus.punch_camera.emit(zoom_scale, offset_strength)
	SignalBus.trigger_camera_shake.emit(offset_strength)
	
	
	if hp <= 0:
		on_died.emit()
		dead = true
		handle_death()
		

func handle_death() -> void:
	queue_free()

func set_marked_visual(mark_visible : bool) -> void:
	if mark_visible:
		celspike_mark.show_sprites()
	else: 
		celspike_mark.hide_sprites()
