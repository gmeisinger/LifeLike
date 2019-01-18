extends PopupPanel

signal choice_made

var blocked = false

func _ready():
	set_process_input(false)
	for button in get_node("choices").get_children():
		button.connect("button_up", self, "_on_button_up", [button.get_text().to_lower()])
		button.connect("button_down", self, "_on_button_down", [button.get_text().to_lower()])
		button.name = button.get_text().to_lower()
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	#set_neighbors()
	
func set_neighbors():
	for index in range(0, len($choices.get_children())):
		var button = $choices.get_child(index)
		#if index > 0:
		#	button.focus_previous = $choices.get_child(index-1).get_path()
			#button.focus_neighbor_top = $choices.get_child(index-1).get_path()
		#if index < len($choices.get_children()):
			#button.focus_next = $choices.get_child(index+1).get_path()
			# = $choices.get_child(index+1).get_path()

func open(msg, _blocked = false):
	blocked = _blocked
	get_tree().set_pause(true)
	get_node("label").set_text(msg)
	popup()
	$choices.get_child(0).grab_focus()
	
func _on_button_up(b_label):
	if blocked:
		global.cprint("unblocked")
		blocked = false
	else:
		get_tree().set_pause(false)
		player_vars.choice_dialog = b_label.to_lower()
		emit_signal("choice_made", b_label.to_lower())
		hide()
		