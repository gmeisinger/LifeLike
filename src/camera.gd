extends Camera2D

var max_offset_x
var max_offset_y
onready var vp_size = get_viewport().get_visible_rect().size

func _ready():
	max_offset_x = vp_size.x/4
	max_offset_y = vp_size.y/4
	pass

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position() - vp_size/2
	offset = Vector2(mouse_pos.x/4, mouse_pos.y/4)
	
