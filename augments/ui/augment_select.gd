class_name AugmentSelectUI
extends CanvasLayer

enum Mode {TEMP, PERM}
var mode : Mode  = Mode.TEMP

const TEMP_STRING : String = "Pick 1 TEMPORARY augment for this fight"
const PERM_STRING : String = "Pick 1 augment to KEEP"

@onready var augment_card_box : GridContainer = %AugmentCardBox
@onready var augment_select_box : Control = %AugmentSelectBox
@onready var title_prompt_label : Label = %TitlePrompt
@onready var lives_prompt_label : Label = %LivesPrompt

@export var augment_card : PackedScene

var curr_selected_augment : Augment 

func _ready() -> void:
	get_tree().paused = true 
	

	augment_select_box.modulate.a = 0
	match mode:
		Mode.PERM : 
			title_prompt_label.text = PERM_STRING
			lives_prompt_label.hide()
		Mode.TEMP : 
			title_prompt_label.text = TEMP_STRING
			lives_prompt_label.text = "Lives Remaining: %d" % GameManager.lives

		
	SignalBus.augment_selected.connect(_update_selected_augment)
	var display_augments : Array[Augment] = ItemGenerator.get_random_augments()
	for augment in display_augments:
		var augment_card_inst : Control = augment_card.instantiate()
		augment_card_box.add_child(augment_card_inst)
		augment_card_inst.populate(augment)
	
	
	show_augment_screen()

func _update_selected_augment(_augment : Augment) -> void:
	curr_selected_augment = _augment

func _on_button_pressed() -> void:
	
	
	if curr_selected_augment == null:
		return
	SFX.play_ui(SFXType.TYPES.CONFIRM_INVENTORY, self)
	match mode:
		Mode.PERM : SignalBus.augment_keep.emit(curr_selected_augment)
		Mode.TEMP : SignalBus.augment_confirm.emit(curr_selected_augment)
	close_augment_screen()

func show_augment_screen() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(augment_select_box, "modulate:a", 1.0, .25)

func close_augment_screen() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(augment_select_box, "modulate:a", 0.0, .25)
	
	await tween.finished
	get_tree().paused = false 
	queue_free()
