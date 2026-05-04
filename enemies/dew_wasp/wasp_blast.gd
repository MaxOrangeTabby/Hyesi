extends Area2D

@export var anim_player : AnimationPlayer
@export var detonate_anim_name : StringName = "detonate"
@export var speed : float = 600
@export var blast_dmg : int = 30

var source_enemy : Enemy

# to be set by the parent
var dir : Vector2 = Vector2(1,-1)


func _physics_process(delta: float) -> void:
	position += dir * speed * delta


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == detonate_anim_name:
		queue_free.call_deferred()


func _on_body_entered(body: Node2D) -> void:
	anim_player.play(detonate_anim_name)
	if body.is_in_group("player_group"):
		body.take_damage(blast_dmg, source_enemy, global_position, 100)
