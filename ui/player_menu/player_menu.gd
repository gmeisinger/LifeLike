extends Popup

onready var tab_container = $TabContainer

func _ready():
	set_process_input(false)
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	#grab focus or active tab
	pass

func open():
	popup()
	get_tree().set_pause(true)
	set_process_input(true)
	pass # replace with function body

func close():
	set_process_input(false)
	hide()
	get_tree().set_pause(false)

func _input(event):
	global.cprint(event.as_text())
	if global.check_input(event.as_text()):
		if event.is_action_pressed("player_game_menu") or event.is_action_pressed("player_b"):
			close()
		elif event.is_action_pressed("player_char_menu"):
			tab_container.current_tab = (tab_container.current_tab + 1) % tab_container.get_tab_count()