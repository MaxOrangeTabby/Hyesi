extends LimboHSM

@export var player : CharacterBody2D
@export var states : Dictionary[String, LimboState]

func _ready() -> void:
	_binding_setup()
	_bb_setup()
	#initialize(player)
	#set_active(true)

func _binding_setup():
	# ADD TRANSITIONS HERE
	add_transition(states["ground"], states["air"], "in_air")
	add_transition(states["ground"], states["celspike"], "do_celspike")
	add_transition(states["ground"], states["aim"], "aim")
	add_transition(states["ground"], states["dash"], "dashing")
	add_transition(states["ground"], states["sword"], "swording")


	add_transition(states["air"], states["ground"], "landing")
	add_transition(states["air"], states["celspike"], "do_celspike")
	add_transition(states["air"], states["aim"], "aim")
	add_transition(states["air"], states["dash"], "dashing")
	add_transition(states["air"], states["sword"], "swording")


	add_transition(states["celspike"], states["air"], "in_air")
	add_transition(states["celspike"], states["ground"], "on_ground")
	add_transition(states["celspike"], states["aim"], "aim")
	add_transition(states["celspike"], states["dash"], "dashing")
	add_transition(states["celspike"], states["sword"], "swording")

	add_transition(states["aim"], states["air"], "in_air")
	add_transition(states["aim"], states["ground"], "on_ground")
	add_transition(states["aim"], states["celspike"], "do_celspike")
	add_transition(states["aim"], states["dash"], "dashing")
	add_transition(states["aim"], states["sword"], "swording")

	add_transition(states["dash"], states["air"], "in_air")
	add_transition(states["dash"], states["ground"], "on_ground")
	add_transition(states["dash"], states["celspike"], "do_celspike")
	add_transition(states["dash"], states["aim"], "aim")
	add_transition(states["dash"], states["sword"], "swording")

	add_transition(states["sword"], states["air"], "in_air")
	add_transition(states["sword"], states["ground"], "on_ground")
	add_transition(states["sword"], states["celspike"], "do_celspike")
	add_transition(states["sword"], states["aim"], "aim")
	add_transition(states["sword"], states["dash"], "dashing")


func _bb_setup():
	# SET VARIABLES HERE
	blackboard.set_var(BBNames.jump_var, false)
	blackboard.set_var(BBNames.faster_fall_var, false)
	blackboard.set_var(BBNames.is_aiming_var, false)
	blackboard.set_var(BBNames.can_move_var, true)
	blackboard.set_var(BBNames.on_floor_var, true)
