extends PopupPanel

func _ready():
	#set_process_input(false)
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	get_node("VBoxContainer/resume").grab_focus()
	pass

func _on_resume_button_up():
	hide()
	get_tree().set_pause(false)

func _on_quit_button_up():
	# SAVE GAME blah
	get_tree().set_pause(false)
	global.goto_title()



func _on_player_open_game_menu():
	popup()
	get_tree().set_pause(true)
