extends Node2D

var line = []

func _ready():
	pass
	
func set_path(points):
	line = points

func _draw():
	if line:
		for seg in range(0,len(line)-1):
			global.cprint(String(line[seg]))
			draw_line(line[seg], line[seg+1], Color(255,0,0), 2.0)

func _process(delta):		
	update()