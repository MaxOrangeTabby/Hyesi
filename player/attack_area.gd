extends Area2D

@export var player : CharacterBody2D
@onready var a1_collider : CollisionShape2D = %A1Collider
@onready var a2_collider : CollisionShape2D = %A2Collider
@onready var a3_collider : CollisionShape2D = %A3Collider

@export var cel_spike_particles : GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if a1_collider:
		a1_collider.disabled = true
	if a2_collider:
		a2_collider.disabled = true
	if a3_collider:
		a3_collider.disabled = true


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		VfxManager.play_anim(VFXType.TYPES.HIT, body)

		if cel_spike_particles:
			cel_spike_particles.restart()
			if player: 
				var dir : Vector2 = (player.global_position - body.global_position).normalized()
				body.process_damage(PlayerKit.handle_out_damage(body), 1.03, 8, dir)
				
			else: 
				body.process_damage(PlayerKit.handle_out_damage(body), 1.03, 8)

func reset_colliders() -> void:
	if a1_collider:
		#a1_collider.disabled = true
		a1_collider.set_deferred("disabled", true)
	if a2_collider:
		#a2_collider.disabled = true
		a2_collider.set_deferred("disabled", true)

	if a3_collider:
		#a3_collider.disabled = true
		a3_collider.set_deferred("disabled", true)
