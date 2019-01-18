extends "res://actors/npcs/npc.gd"

const COMFORT_THRESHOLD = 5
const VISIT_THRESHOLD = 1
const MIN_VISIT = 5.0

var timer
var spot
var exit
onready var visiting = true
onready var comfortable = false
onready var visit_length = 0.0



func init():
	.init()
	set_spot(find_new_spot())
	global.cprint(spot.name)
	dest = spot.get_random_position()
	nav_on = true
	free_nav = true
	pass

func set_spot(_spot):
	spot = _spot
	dest = spot.get_position()
	nav_on = true
	
func set_exit(_exit):
	exit = _exit
	
func on_timeout():
	var roll = global.get_random_number(0,10)
	if roll < VISIT_THRESHOLD and visiting:
		visiting = false
		comfortable = false
	elif roll < COMFORT_THRESHOLD and comfortable:
		comfortable = false
	dest = find_new_target()
	global.cprint(String(dest))
	
func find_new_target():
	#should we remove from scene?
	if dest == exit.get_position():
		queue_free()
	if comfortable:
		return null
	elif visiting:
		#spot.available = true
		spot = find_new_spot()
		return spot.get_position()
	else:
		return exit.get_position()
		
func find_new_spot():
	var locs = global.get_cur_scene().active_area.get_node("locs").get_children()
	for loc in locs:
		if !loc.available:
			locs.erase(loc)
	if !locs:
		comfortable = false
		visiting = false
		return exit
	comfortable = true
	var rint = global.get_random_number(0, locs.size())
	var new_spot = locs[rint]
	print(String(locs))
	new_spot.available = false
	if spot:
		spot.available = true
	global.cprint("new spot: "+new_spot.name)
	return new_spot
	
func _physics_process(delta):
	._physics_process(delta)