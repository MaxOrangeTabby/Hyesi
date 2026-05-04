extends ProgressBar

var hp_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_hp_changed.connect(_update_hp)
	max_value = PlayerKit.hp
	value = PlayerKit.hp

func _update_hp(current_hp : float, max_hp : float) -> void:
	if max_hp != max_value:
		max_value = max_hp
	
	if hp_tween and hp_tween.is_running():
		hp_tween.kill()
	hp_tween = create_tween()
	hp_tween.set_ease(Tween.EASE_OUT)
	hp_tween.tween_property(self, "value", current_hp, .25)
