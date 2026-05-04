class_name RockGolem
extends Enemy


@export var gravity : float = 2500
@export var term_vel: float = 1400
@export var friction : float = 4000


@export var anim_player : AnimationPlayer
@export var stats : BaseEnemyStats

@export var smash_dmg : int = 12
@export var flip_root : Node2D


var player_in_range : bool = false
var player : CharacterBody2D 

var player_in_attack_range : bool = false
var attacking : bool = false
var attack_anim_name : StringName = "attack"
var run_anim_name : StringName = "run"

var faster_fall : bool = false
var prev_x_direction : float 


func _ready() -> void:
	hp = max_hp
	

func _process(delta: float) -> void:
	apply_grav(delta)
	var direction : Vector2
	if attacking:
		return
	if player:
		direction = (player.global_position - global_position).normalized()
		if direction.x > .01:
			flip_root.scale.x  = -abs(flip_root.scale.x)
		elif direction.x < -.01:
			flip_root.scale.x  = abs(flip_root.scale.x)
	
	if player and player_in_attack_range:
		attacking = true
		velocity.x = 0
		attack_player()
	elif player and player_in_range:
		velocity.x = stats.speed * sign(direction.x)
		anim_player.play(run_anim_name)
	else:
		velocity.x = 0.0
	move_and_slide()


func apply_grav(delta : float) -> void: 
	velocity.y += gravity * delta
	velocity.y = (3 * velocity.y)/4 if faster_fall and velocity.y < 0 else velocity.y
	velocity.y = min(velocity.y, term_vel)


func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		print("detect player")
		player_in_range = true
		player = body


func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_range = false
		player = null

func attack_player() -> void:
	anim_player.play(attack_anim_name)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == attack_anim_name:
		attacking = false


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_attack_range = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_attack_range = false

func handle_death() -> void:
	var loot_count : int = randi_range(1, loot_spawn_count)
	for i in loot_count: 
		var item_inst = DROPPED_ITEM_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(item_inst)
		item_inst.global_position = global_position
	
	queue_free.call_deferred()


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.take_damage(smash_dmg, self, global_position, 1000)


func _on_before_arena_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
