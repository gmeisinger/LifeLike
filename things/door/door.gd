extends "res://things/thing.gd"

export(bool) var locked = false
export(bool) var change_scene = false
export(bool) var change_area = false
export(String, MULTILINE) var locked_msg = "Locked..."
export(String, MULTILINE) var travel_msg = "Enter?"
export(String) var key = null
export(String) var destination = null
export(String) var dest_position = null
export(String) var dest_face = "up"

func interact():
	if locked:
		unlock()
	else:
		if change_scene:
			switch_scene(destination, dest_position, dest_face)
		elif change_area:
			switch_area(destination, dest_position, dest_face)
		elif dest_position:
			move_player(dest_position, dest_face)
		else:
			open()
			
func switch_scene(_dest, _dest_pos, _dest_face):
	global.goto_scene(_dest, _dest_pos, _dest_face)
	
func switch_area(_dest, _dest_pos, _dest_face):
	global.get_cur_scene().set_active_area(_dest, _dest_pos, _dest_face)

func move_player(_dest_position, _dest_face):
	var pos = global.get_cur_scene().find_location(_dest_position)
	global.get_player().set_position(pos.get_position())
	global.get_player().facing = _dest_face
	

func unlock():
	#attempts to open the door by checking player inventory for key
	emit_signal("open_dialog", locked_msg)
	
func open():
	pass	#by open I mean remove sprite and collision