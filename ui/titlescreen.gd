extends ViewportContainer

var icon_locs
onready var icon = get_node("icon")

func _ready():
	var icon_size = icon.get_rect().size
	var newgame = get_node("newgame").get_position() - Vector2(icon_size.x,icon_size.y/4)
	var loadgame = get_node("loadgame").get_position() - Vector2(icon_size.x,icon_size.y/4)
	var quit = get_node("quit").get_position() - Vector2(icon_size.x,icon_size.y/4)
	icon_locs = {
		newgame = newgame,
		loadgame = loadgame,
		quit = quit
		}
	get_node("newgame").grab_focus()
	pass


func _on_quit_button_up():
	get_tree().quit()
	pass # replace with function body


func _on_newgame_button_up():
	global.goto_scene("neighborhood", "door_home", "down")
	pass # replace with function body


func _on_newgame_focus_entered():
	icon.set_position(icon_locs["newgame"])
	pass # replace with function body


func _on_loadgame_focus_entered():
	icon.set_position(icon_locs["loadgame"])	
	pass # replace with function body


func _on_quit_focus_entered():
	icon.set_position(icon_locs["quit"])	
	pass # replace with function body
