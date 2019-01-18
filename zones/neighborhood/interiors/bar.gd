extends "res://zones/area.gd"

const MAX_VISITOR = 5
const VISITORS = ["miguel", "dwight", "tommy"]
const SPAWN_DELAY = 10	#seconds

onready var visitor_script = preload("res://actors/npcs/scripts/visitor.gd")

var npc_messages = [
	"I need a drink!",
	"Hey, wanna party?",
	"Yo man, where can I score some drugs?",
	"Where are all the chicks?"
	]

func _process(delta):
	spawn_timer += delta
	if spawn_timer > SPAWN_DELAY:
		global.cprint("Spawning Bar NPC...")
		var npc = spawn_visitor($locs/door, $locs/door)
		global.cprint(npc.name)
		if npc:
			npc.msg = pick_message()
			$objects.add_child(npc)
		spawn_timer = 0
		
func pick_message():
	var rand_int = global.get_random_number(0, len(npc_messages))
	return npc_messages[rand_int]
	
func spawn_visitor(enter = null, exit = null):
	if spawns.size() > 0 and spawn_count < MAX_VISITOR:
		var enter_index
		var exit_index
		if !enter:
			enter_index = global.get_random_number(0,spawns.size())
			enter = spawns[enter_index]
		if !exit:
			exit_index = enter_index
			exit = spawns[exit_index]
		var new_npc = new_npc(visitor_script)
		npc_random_sprite(new_npc)
		new_npc.set_position(enter.get_position())
		new_npc.set_exit(exit)
		new_npc.init()
		spawn_count += 1
		return new_npc

func npc_random_sprite(npc):
	var rand_int = global.get_random_number(0, len(VISITORS))
	var tex = VISITORS[rand_int]
	npc.set_sprite(tex)