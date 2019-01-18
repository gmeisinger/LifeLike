extends "res://actors/npcs/npc.gd"

func _ready():
	nav_on = true
	dest = find_new_target()

func find_new_target():
	var locations = global.get_cur_scene().active_locs
	if locations:
		return locations[global.get_random_number(0, locations.size())].get_position()
	else:
		return null
		
func _physics_process(delta):
	._physics_process(delta)
	if not dest:
		dest = find_new_target()