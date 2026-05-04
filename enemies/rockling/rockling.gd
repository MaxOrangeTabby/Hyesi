extends Enemy

enum State {PATROL, CHASE, ATTACK}

@export var gravity : float = 1200

@export var sprite : Sprite2D

@export var anim_player : AnimationPlayer
@export var btplayer : BTPlayer

@export var l_raycast : RayCast2D
@export var r_raycast: RayCast2D
@export var patrol_speed : float = 100
@export var chase_speed : float = 200

@export var atk_dmg : int = 15
@export var atk_cd : float = 1.5

var state : State = State.PATROL
var player : CharacterBody2D
var patrol_dir : int = 1
var can_attack : bool = true
var player_in_attack_range : bool = false
var _patrol_pause_until : float = 0.0

func _ready() -> void:
	hp = max_hp
	anim_player.play("walk")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 20.0

	match state :
		State.PATROL : 
			anim_player.play("walk")
			_do_patrol()
		State.CHASE : 
			anim_player.play("walk")
			_do_chase()
		State.ATTACK : velocity.x = 0

	if can_attack and player_in_attack_range and state != State.ATTACK:
		_do_attack()

	move_and_slide()

func _do_patrol() -> void:
	if Time.get_ticks_msec() / 1000.0 < _patrol_pause_until:
		velocity.x = 0
		return
	velocity.x  = patrol_speed * patrol_dir
	sprite.flip_h = patrol_dir > 0
	
	if is_on_wall():
		_flip_patrol()
		return
	var forward_ray : RayCast2D = r_raycast if patrol_dir > 0 else l_raycast
	if is_on_floor() and not forward_ray.is_colliding():
		_flip_patrol()

func _flip_patrol() -> void:
	patrol_dir *= -1
	_patrol_pause_until = (Time.get_ticks_msec() / 1000) + .3

func _do_chase() -> void:
	if not is_instance_valid(player):
		state = State.PATROL
		return
	var dx : float = (player.global_position.x - global_position.x)
	if abs(dx) < 10:
		velocity.x  = 0
		return
	var dir : int = sign(player.global_position.x - global_position.x)
	velocity.x = chase_speed * dir
	sprite.flip_h = dir > 0

func _do_attack() -> void:
	if not can_attack: return
	can_attack = false
	state = State.ATTACK
	anim_player.play("attack")
	await anim_player.animation_finished
	await get_tree().create_timer(atk_cd).timeout
	state = State.CHASE if is_instance_valid(player) else State.PATROL
	can_attack = true



func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player = body
		if state == State.PATROL:
			state = State.CHASE
			

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player = null
		if state == State.ATTACK:
			state = State.PATROL


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_attack_range = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_in_attack_range = false

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		body.take_damage(attack_dmg, self, global_position, 350)

func handle_death() -> void:
	var loot_count : int = randi_range(1, loot_spawn_count)
	for i in loot_count: 
		var item_inst = DROPPED_ITEM_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(item_inst)
		item_inst.global_position = global_position
	
	queue_free.call_deferred()
