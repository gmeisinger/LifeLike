extends "res://zones/area.gd"

const MAX_PASSERBY = 10
const MAX_ENEMY = 10
const PASSERBYS = ["miguel", "dwight", "tommy"]
const SPAWN_DELAY = 5	#seconds

enum { DAY, NIGHT }
onready var state = DAY

var npc_messages = [
	"Just passin' through, bud...",
	"Excuse me, I'm trying to check my twitter here...",
	"Hey!\n\nFollow me on Instagram!! :)",
	"Move it, I'm late for work.",
	"Which way is downtown??",
	"Did you update your phone yet?\nThey just added 4000 new emojis!",
	"No time to talk, send me a text!"
	]

func _ready():
	pass


func _process(delta):
	spawn_timer += delta
	if spawn_timer > SPAWN_DELAY:
		spawn_timer = 0
		if spawn_count < MAX_PASSERBY:
			var npc = spawn_passerby()
			npc.msg = pick_message()
			spawn_count += 1
		
func pick_message():
	var rand_int = global.get_random_number(0, len(npc_messages))
	return npc_messages[rand_int]
	
func spawn_passerby(enter = null, exit = null):
	if spawns.size() > 0:
		var enter_index
		if !enter:
			enter_index = global.get_random_number(0,spawns.size())
			enter = spawns[enter_index]
		if !exit:
			var exit_index = enter_index
			while exit_index == enter_index:
				exit_index = global.get_random_number(0,spawns.size())
				exit = spawns[exit_index]
		var new_npc = new_npc()
		npc_random_sprite(new_npc)
		new_npc.set_script(passerby_script)
		new_npc.set_position(enter.get_position())
		new_npc.set_exit(exit.get_position())
		new_npc.init()
		return new_npc

func spawn_enemy(enter = null):
	if spawns.size() > 0 and spawn_count < MAX_ENEMY:
		var enter_index
		if !enter:
			enter_index = global.get_random_number(0,spawns.size())
			enter = spawns[enter_index]
		var new_enemy = new_enemy()
		new_enemy.set_position(enter.get_position())
		new_enemy.start_pos = global.get_player().get_position()
		new_enemy.init()
		spawn_count += 1
		return new_enemy

func npc_random_sprite(npc):
	var rand_int = global.get_random_number(0, len(PASSERBYS))
	var tex = PASSERBYS[rand_int]
	npc.set_sprite(tex)