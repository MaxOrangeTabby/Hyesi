extends Area2D

@export var contact_terrain_anim_name : StringName = "contact_terrain"
@export var contact_enemy_anim_name : StringName = "contact_enemy"

@export var anim_sprite : AnimatedSprite2D 
@export var cel_spike : CharacterBody2D
@export var cel_spike_particles : GPUParticles2D
@export var cel_spike_collider : CollisionShape2D

@export var celspike_lifetime : float = 1.5
@export var celspike_mark : Node2D

@export var player_stats : PlayerStats


func _on_body_entered(body: Node2D) -> void:
	#rint("BODY ENTERED:  ", body)
	#cel_spike_collider.set_deferred("disabled", true)
	set_deferred("monitoring",false)
	
	if body.is_in_group("spikable_group"):
		cel_spike_collider.set_deferred("disabled", false)
		celspike_mark.show_sprites()
		cel_spike.can_move = false
		cel_spike.velocity = Vector2.ZERO
		anim_sprite.play(contact_terrain_anim_name)
		play_hit_particle()
		await anim_sprite.animation_finished
		#call_deferred("queue_free")
	
	elif body.is_in_group("enemy_group"):
		var dmg : float = PlayerKit.handle_out_damage(body)
		if cel_spike and cel_spike.is_focused:
			dmg *= PlayerKit.charged_celspike_dmg_mult
		body.process_damage(dmg, 1.01, 14)
		
		if PlayerKit.marked_enemy and PlayerKit.marked_enemy != body:
			PlayerKit.marked_enemy.set_marked_visual(false)
		PlayerKit.marked_enemy = body
		body.set_marked_visual(true)
		
		PlayerKit.on_hit.emit({
			"enemy" : body,
			"damage_done" : player_stats.cel_spike_dmg
		})
		
		
		cel_spike.can_move = false
		anim_sprite.play(contact_enemy_anim_name)
		play_hit_particle()

func play_hit_particle() -> void:
	cel_spike_particles.restart
	cel_spike_particles.emitting = true
	await cel_spike_particles.finished
	await get_tree().create_timer(celspike_lifetime).timeout
	_queue_free_self()

func _queue_free_self() -> void: 
	cel_spike.queue_free.call_deferred()
