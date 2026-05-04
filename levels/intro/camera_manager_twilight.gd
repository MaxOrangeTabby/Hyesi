extends Node

@export var player : CharacterBody2D
@export var camera_zone0 : PhantomCamera2D
@export var camera_zone1 : PhantomCamera2D
@export var camera_zone2 : PhantomCamera2D
@export var camera_zone3 : PhantomCamera2D
@export var camera_zone4 : PhantomCamera2D


var current_camera_zone : int = 0
var current_bodies_touch : int = 0

func _ready() -> void:
	camera_zone0.priority = 1


func _process(delta: float) -> void:
	pass
	#await get_tree().create_timer(5).timeout
	#print("current body: ", current_bodies_touch)


func update_camera() -> void:
	var camera_arr = [camera_zone0, camera_zone1, camera_zone2]
	for camera in camera_arr:
		if camera != null:
			camera.priority = 0
	match current_camera_zone:
		0:
			camera_zone0.priority = 1
		1:
			camera_zone1.priority = 1


# checks if the player is touching 2 areas
func check_for_switch() -> void:
	if current_bodies_touch == 0:
		update_camera()


func _on_z_0_body_entered(body: Node2D) -> void:
	print("PASS")
	if body.is_in_group("player_group"):
		current_bodies_touch += 1
		current_camera_zone = 0
		check_for_switch()

func _on_z_0_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		current_bodies_touch -= 1
		current_camera_zone = 0
		check_for_switch()

func _on_z_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		current_bodies_touch += 1
		current_camera_zone = 1
		check_for_switch()

func _on_z_1_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		current_bodies_touch -= 1
		current_camera_zone = 1
		check_for_switch()


func _on_z_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		current_bodies_touch += 1
		current_camera_zone = 2
		check_for_switch()


func _on_z_2_body_exited(body: Node2D) -> void:
		if body.is_in_group("player_group"):
			current_bodies_touch -= 1
			current_camera_zone = 2
			check_for_switch()
