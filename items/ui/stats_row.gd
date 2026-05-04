extends MarginContainer

@onready var stat_name_label : Label = %StatNameLabel
@onready var stat_val_label : Label = %StatValueLabel

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass

func create_stats_row(stat_name : String, stat_val : float, stat_type : String) -> void:
	

		
	stat_name_label.text = stat_name
	stat_val_label.text = "+" +  str(stat_val)
	
	if stat_type == "flat":
		stat_val = roundi(stat_val)
		stat_val_label.text = "+%.0f" % stat_val

		
	if stat_type == "percentage":
		stat_val_label.text += "%"
