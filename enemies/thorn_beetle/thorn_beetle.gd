extends Enemy

@export var gravity : float = 2500
@export var velocity_x : float = 1000

@export var sprite : Sprite2D

@export var anim_player : AnimationPlayer
@export var btplayer : BTPlayer

@export var l_raycast : RayCast2D
@export var r_raycast: RayCast2D

@export var dash_dmg : int = 15

var blackboard : Blackboard
var player : CharacterBody2D 
var is_active : bool 

const BBVars = BBNames.EnemyBBNames

func _ready() -> void:
	blackboard = btplayer.blackboard
	btplayer.active = false
	
	blackboard.set_var(BBVars.player_ref_var, null)
	blackboard.set_var(BBVars.player_detected_var, false)
	blackboard.set_var(BBVars.x_dir_var, 1)
	blackboard.set_var(BBVars.change_dir_var, true)

	blackboard.bind_var_to_property(BBVars.is_active_var, self, "is_active")
	activate()

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	if player:
		var direction_to_player : Vector2 = player.global_position - global_position
		if not is_zero_approx(direction_to_player.x):
			pass
			#face_dir(direction_to_player)
	move_and_slide()

func deactivate() -> void:
	is_active = false
	btplayer.active = false

func activate() -> void:
	is_active = true
	btplayer.active = true

func get_anim_player():
	if anim_player:
		return anim_player

func face_dir(dir : Vector2):
	if not blackboard.get_var(BBVars.change_dir_var):
		return
	if dir.x == 0:
		return
	sprite.flip_h = dir.x > 0

func handle_death() -> void:
	var loot_count : int = randi_range(1, loot_spawn_count)
	for i in loot_count: 
		var item_inst = DROPPED_ITEM_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(item_inst)
		item_inst.global_position = global_position
	
	queue_free.call_deferred()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		print("FIRE PLAYER IN RANGE THORN BEETLE")
		blackboard.set_var(BBVars.player_ref_var, body)
		blackboard.set_var(BBVars.player_detected_var, true)

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player = null
		blackboard.set_var(BBVars.player_ref_var, null)
		blackboard.set_var(BBVars.player_detected_var, false)
		blackboard.set_var(BBVars.change_dir_var, true)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		print("palyer in attack range")
		blackboard.set_var(BBVars.in_range_var, true)

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		blackboard.set_var(BBVars.in_range_var, false)
		blackboard.set_var(BBVars.change_dir_var, true)


func _on_dash_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.take_damage(dash_dmg, self, global_position, 1200)
