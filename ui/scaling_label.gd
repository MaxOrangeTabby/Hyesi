extends Label


@export var max_font_sz : int = 80
@export var min_font_sz : int = 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_font_sz = get_theme_font_size("font_size")
	resized.connect(fit_text)
	fit_text()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fit_text() -> void:
	var curr_font_sz : int  = max_font_sz
	
	while(curr_font_sz > min_font_sz):
		add_theme_font_size_override("font_size", curr_font_sz)
		
		if get_minimum_size().x < size.x:
			break;
		
		curr_font_sz-=1
			
