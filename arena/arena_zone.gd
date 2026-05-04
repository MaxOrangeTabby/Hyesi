extends Area2D

@export var arena_num : int 
@export var boss : CharacterBody2D
@export var gate : StaticBody2D

var arena_locked : bool = false
var player_ref : Node2D
var arena_won : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	SignalBus.boss_fight_lost.connect(_on_boss_fight_lost)
	SignalBus.arena_finished.connect(_on_arena_won)
	if boss:
		boss.on_died.connect(_on_boss_died)
	
	if gate:
		gate.modulate.a = 0.0
		gate.hide()
		gate.process_mode = Node.PROCESS_MODE_DISABLED

func activate_arena(player: Node2D)->void: 
	player_ref = player 
	arena_locked = true

	GameManager.current_arena_start = player.global_position
	GameManager.lives = GameManager.MAX_LIVES
	
	SignalBus.arena_entered.emit(arena_num)
	_set_gate(true)
	boss.activate_fight(player)

func _on_body_entered(body: Node2D) -> void:
	if arena_locked or arena_won: 
		return
	if not body.is_in_group("player_group"):
		return
	activate_arena(body)

func _on_boss_fight_lost(num : int) -> void:
	if num != arena_num:
		return
	arena_locked = false
	_set_gate(false)
	boss.reset_fight()

func _on_arena_won(_num : int = -1) -> void:
	if _num != arena_num:
		return
	if not arena_locked:
		return
	arena_locked = false
	arena_won = true
	_set_gate(false)

func _set_gate(active : bool) -> void:
	if gate == null:
		return 
	if active:
		gate.process_mode = Node.PROCESS_MODE_INHERIT
		gate.show()
		var t : Tween = create_tween()
		t.tween_property(gate, "modulate:a", 1.0, .3).from(0.0)
	else:
		var t : Tween = create_tween()
		t.tween_property(gate, "modulate:a", 0.0, .3).from_current()
		t.tween_callback(gate.hide)
		t.tween_callback(func() : gate.process_mode = Node.PROCESS_MODE_DISABLED)

func _on_boss_died() -> void:
	if not arena_locked:
		return
	SignalBus.arena_finished.emit(arena_num)
