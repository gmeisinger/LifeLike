extends "res://actors/actor.gd"

signal arrived_at_dest

#constants
const WAIT_DIST = 64.0
const ARRIVE_DIST = 30.0

export(String, MULTILINE) var msg = "Hi!"

enum {WALKING, IDLE, SEEKING, ATTACKING, RECOILING}
var idle_action = "idle"
var state = IDLE
var player
var nav
var path = []
onready var nav_on = false
onready var free_nav = false
var dest

var passerby_sprites = {
	miguel = preload("res://actors/npcs/sprites/miguel.png"),
	police = preload("res://actors/npcs/sprites/police.png"),
	dwight = preload("res://actors/npcs/sprites/dwight.png"),
	tommy = preload("res://actors/npcs/sprites/tommy.png")
}

#test vars
var debug = true
var debug_timer = 0

func _ready():
	facing = "down"
	play_anim("idle")
	nav = global.search_node("map")
	player = global.search_node("player")

func init():
	.init()
	is_init = true
	#print(String(anims))

func interact():
	emit_signal("open_dialog", msg)
	yield(global.search_node("dialog"), "popup_hide")

func move_away(pos):
	vel = (get_position() - pos).normalized() * (WALK_FORCE * vel_mod)

func circle(pos, lefty = false):
	vel = (pos - get_position()).normalized().tangent() * (WALK_FORCE * vel_mod)
	if lefty:
		vel = -vel

func update_state():
	match(state):
		IDLE:
			play_anim(idle_action)
			if vel.x or vel.y:
				state = WALKING
			else:
				state = SEEKING
		WALKING:
			if !vel.x and !vel.y:
				state = IDLE
			else:
				play_anim("walk")
			#######
			if nav_on:
				state = SEEKING
		SEEKING:
			if distance(global.get_player().get_position()) < WAIT_DIST:
				state = IDLE
				look_at(global.get_player().get_position())
			elif nav_on and dest:
				if distance(dest) < ARRIVE_DIST:
					emit_signal("arrived_at_dest", self)
					dest = find_new_target()
				if dest:
					navigate(dest)	
					state = WALKING
				else:
					state = IDLE
	
func find_new_target():
	pass

func navigate(_dest):
	if _dest == get_position():
		return
	#var direction = nav.get_simple_path(map.world_to_map(get_position()), dest)
	var pos = get_position()
	path = global.get_cur_scene().active_area.get_node("map").get_path(pos, _dest, free_nav)
	if not path or len(path) == 1:
		state = IDLE
		return
		#get_owner().emit_signal("console_add", String(direction[0].normalized()))
	vel = (path[1] - pos).normalized() * (WALK_FORCE * 2) * vel_mod

func set_sprite(tex_name):
	get_node("sprite").set_texture(passerby_sprites[tex_name])

func set_random_sprite():
	var rand = global.get_random_number(0, passerby_sprites.size())
	var vals = passerby_sprites.values()

func _physics_process(delta):
	#timer += delta
	if not is_init:
		init()
	update_state()
	._physics_process(delta)