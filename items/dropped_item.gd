extends CharacterBody2D


@onready var player_detector : Area2D = %PlayerDetector
@onready var prompt_label : Label = %PromptLabel
@onready var main_sprite : AnimatedSprite2D = %MainSprite

@export var gravity : float = 900
@export var collection_timer : Timer

var item : Item
var move_tween : Tween
var player_in_range : bool = false
var player : CharacterBody2D
var item_collected : bool = false

func _ready() -> void:
	item = ItemGenerator.generate()
	prompt_label.visible = false


func _process(delta: float) -> void:
	if item_collected:
		if player:
			var dist_to_player = player.global_position.distance_to(global_position)
			var speed = lerp(10.0, 550.0, (1000.0 - dist_to_player) / 200.0)
			
			# abs to avoid a negative delta
			global_position = global_position.move_toward(player.global_position, abs(speed * delta))
	if not is_on_floor():
		velocity.y += gravity
	else:
		velocity.y = 0
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact1") and player_in_range:
		collection_timer.start()
		item_collected = true

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player = body
		player_in_range = true
		prompt_label.visible = true
 
		var tween = create_tween()
		tween.tween_property(prompt_label, "modulate:a", 1.0, .4)
		
		move_tween = create_tween()
		move_tween.set_loops()
		move_tween.tween_property(prompt_label, "position:y", prompt_label.position.y - 10, .4)
		move_tween.tween_property(prompt_label, "position:y", prompt_label.position.y + 10, .4)
		tween.set_loops()
 

func _on_player_detector_body_exited(body: Node2D) -> void:
	player = null
	player_in_range = false
	if body.is_in_group("player_group"):
		var tween = create_tween()
		tween.tween_property(prompt_label, "modulate:a", 0.0, .4)
		await tween.finished
		prompt_label.visible = false

#func item_collected() -> void:
	#if player:
		#var tween =  create_tween()
		##tween.set_parallel(true)
		#
		#tween.set_trans(Tween.TRANS_SINE)
		#tween.set_ease(Tween.EASE_OUT)
		#tween.tween_property(self, "position", position - Vector2(80, 180), .2)
		#tween.tween_property(self, "global_position", player.global_position, .3)
#
		#await tween.finished
		#SignalBus.item_collected.emit(item)
	#queue_free()


func _on_collection_timer_timeout() -> void:
	item_collected = false
	SignalBus.item_collected.emit(item)
	queue_free()
