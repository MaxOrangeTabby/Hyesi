extends CanvasLayer

@export var player_actions : PlayerActions
@export var control_panel : Control
@export var inventory_scale : Vector2 = Vector2(0.7, 0.7)

@onready var item_card_box : Control = %ItemCardBox
@onready var inventory_margins : MarginContainer = %InventoryMargins
@onready var item_slot_box : GridContainer = %ItemSlotBox
@onready var scroll_box : ScrollContainer = %ScrollContainer


var item_card : PackedScene = preload("uid://biqh2wxom4kp1")
var item_slot : PackedScene = preload("uid://d1b5jfrrtqesq")


var current_item_card : ItemCard
var set_pivot_offset : bool = false
var is_open : bool = false
var card_created : bool = false


func _ready() -> void:
	scroll_box.get_v_scroll_bar().step = 28
	
	SignalBus.item_slot_clicked.connect(update_item_card)
	SignalBus.item_collected.connect(add_item)
	
	item_card_box.visible = false
	inventory_margins.visible = false
	close()

func _process(delta: float) -> void:
	if not set_pivot_offset: 
		print("control pannel s:z", control_panel.size)
		control_panel.pivot_offset = control_panel.size / 2.0
		set_pivot_offset = true
	if Input.is_action_just_pressed(player_actions.open_inventory):
		if is_open:
			close()
		else:
			open()


func open() -> void:
	visible = true
	is_open = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(control_panel, "scale", inventory_scale, 0.2)


func close() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(control_panel, "scale", Vector2.ZERO, 0.2)
	
	visible = false
	is_open = false


func update_item_card(item_clicked : Item) -> void:
	print("UPDATE CARD")
	item_card_box.visible = true
	inventory_margins.visible = true

	# if the card has not been created yet, create one then save it
	if not card_created:
		card_created = true
		var item_card_instance = item_card.instantiate()
		item_card_box.add_child(item_card_instance)
		item_card_instance.create_card(item_clicked)
		current_item_card = item_card_instance
	else:
		current_item_card.create_card(item_clicked)

func add_item(item_collected : Item):
	var item_slot_instance = item_slot.instantiate()
	item_slot_box.add_child(item_slot_instance)
	print("create object: ", item_collected.rarity)
	item_slot_instance.create_item_slot(item_collected, item_collected.name, item_collected.rarity)
