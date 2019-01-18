extends "res://actors/npcs/npc.gd"

var following = false
onready var start_pos = get_position()
onready var start_area = global.get_cur_scene().active_id
onready var question = "Do you want " + name.capitalize() + " to follow you around?"

func _ready():
	._ready()
	vel_mod = 1.5
	

func find_new_target():
	if following:
		return player.get_position()
	elif distance(start_pos) <= ARRIVE_DIST :
		nav_on = false
		set_position(start_pos)
		state = IDLE
		return start_pos
	else:
		return start_pos
		
func interact():
	.interact()
	yield(global.search_node("dialog"), "popup_hide")
	emit_signal("open_choice_dialog", question, true)
	yield(global.search_node("choice_dialog"), "choice_made")
	global.cprint(player_vars.choice_dialog)
	if player_vars.choice_dialog == "yes": 
		player_vars.set_follower(self)
		nav_on = true
		free_nav = true
		following = true
	else:
		following = false
		dest = find_new_target()
	
func _physics_process(delta):
	dest = find_new_target()
	._physics_process(delta)