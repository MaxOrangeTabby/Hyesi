extends Node

const AUGMENT_SCREEN : PackedScene = preload("uid://dtp0o8yqrp251")
const MAX_LIVES : int = 3

var in_boss_fight : bool = false
var lives : int =  3
var current_arena_start : Vector2 = Vector2.ZERO
var current_arena_num : int = -1
var time_tween : Tween

#signal req_time_slow(scale : float, duration : float)
#signal reset_time_slow() # brings it back to 1.0
#signal start_time_slow(scale : float) # tween to the given time slow

var slow_token : int = 0
var current_scene_start : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SignalBus.player_die.connect(show_augment_selection)
	SignalBus.req_time_slow.connect(_handle_time_slow)
	SignalBus.reset_time_slow.connect(_reset_time_scale)
	SignalBus.start_time_slow.connect(_slow_time_scale)
	
	SignalBus.player_die.connect(_on_player_die)
	SignalBus.arena_entered.connect(_on_arena_entered)
	SignalBus.arena_finished.connect(_on_arena_finished)
	

func show_augment_selection(mode : int) -> void:
	var augment_screen_inst : CanvasLayer = AUGMENT_SCREEN.instantiate()
	augment_screen_inst.mode = mode
	get_tree().root.add_child(augment_screen_inst)

func _slow_time_scale(scale : float) -> void: 
	if time_tween and time_tween.is_running():
		time_tween.kill()
	
	time_tween = create_tween()
	time_tween.set_ignore_time_scale(true)
	time_tween.set_ease(Tween.EASE_IN)
	time_tween.set_trans(Tween.TRANS_CUBIC)
	time_tween.tween_method(set_engine_scale, Engine.time_scale, scale, .25)

func _reset_time_scale() -> void:
	if time_tween and time_tween.is_valid():
		time_tween.kill()
	
	time_tween = create_tween()
	time_tween.set_ignore_time_scale(true)
	time_tween.set_ease(Tween.EASE_IN)
	time_tween.set_trans(Tween.TRANS_CUBIC)
	time_tween.tween_method(set_engine_scale, Engine.time_scale, 1.0, .25)

func _handle_time_slow(scale : float, duration : float) -> void:
	slow_token += 1
	var curr_token : int = slow_token
	
	_slow_time_scale(scale)
	await get_tree().create_timer(duration, false, false, true).timeout
	
	if curr_token == slow_token:
		_reset_time_scale()

func set_engine_scale(new_scale : float):
	Engine.time_scale = new_scale


func _on_arena_entered(arena_num : int) -> void:
	in_boss_fight = true
	current_arena_num = arena_num

func _on_arena_finished(_num : int) -> void:
	in_boss_fight = false
	show_augment_selection(AugmentSelectUI.Mode.PERM)

func _on_player_die() -> void:
	if not in_boss_fight:
		print("not boss fight")
		return
	lives -= 1
	if lives <= 0:
		_game_over()
		return
	show_augment_selection(AugmentSelectUI.Mode.TEMP)

func _game_over() -> void: 
	lives = MAX_LIVES
	in_boss_fight = false
	PlayerKit.clear_temp_augments()
	SignalBus.boss_fight_lost.emit(current_arena_num)
	current_arena_num = -1
