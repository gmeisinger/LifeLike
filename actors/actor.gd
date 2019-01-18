extends KinematicBody2D

signal open_dialog
signal open_choice_dialog

const WALK_FORCE = 30
var FRICTION = 1.2
const MAX_SPEED = 160
const POS_ADJUSTMENT = -24

var anims_left
var anims_right
var anims_up
var anims_down
var anims
var vel = Vector2()
export var vel_mod = 1.0
var moving = false
onready var facing = "down"
onready var is_init = false
var limit_vel = true

func init():
	facing = "down"
	anims_left = {
		walk = "walk_left",
		idle = "idle_left",
		hooray = "hooray_left"
		}
	anims_right = {
		walk = "walk_right",
		idle = "idle_right",
		hooray = "hooray_right"
		}
	anims_down = {
		walk = "walk_down",
		idle = "idle_down",
		hooray = "hooray_down"
		}
	anims_up = {
		walk = "walk_up",
		idle = "idle_up",
		hooray = "hooray_up"
		}
	anims = {
		left = anims_left,
		right = anims_right,
		up = anims_up,
		down = anims_down,
		up_left = {},
		up_right = {},
		down_left = {},
		down_right = {}
		}
	pass

func _ready():
	$sprite.set_position(Vector2(0,POS_ADJUSTMENT))
	$col_physics.set_position(Vector2(0,POS_ADJUSTMENT))
	$interact.set_position(Vector2(0,POS_ADJUSTMENT))
	facing = "down"
	anims_left = {
		walk = "walk_left",
		idle = "idle_left",
		hooray = "hooray_left"
		}
	anims_right = {
		walk = "walk_right",
		idle = "idle_right",
		hooray = "hooray_right"
		}
	anims_down = {
		walk = "walk_down",
		idle = "idle_down",
		hooray = "hooray_down"
		}
	anims_up = {
		walk = "walk_up",
		idle = "idle_up",
		hooray = "hooray_up"
		}
	anims = {
		left = anims_left,
		right = anims_right,
		up = anims_up,
		down = anims_down
		}
	pass
	
func _physics_process(delta):
	#take input/do ai
	update_facing()
	
	var collision = move_and_collide(vel * delta)
	if collision:
    	vel = vel.slide(collision.normal)
	vel = vel/FRICTION
	if abs(vel.x) < 2:
		vel.x = 0
	if abs(vel.y) < 2:
		vel.y = 0
	
func distance(_dest):
	var dist = 0
	if _dest:
		dist = get_position().distance_to(_dest)
	return dist
	
func update_facing():
	if vel.x > 0 and abs(vel.x) > abs(vel.y):
		facing = "right"
	elif vel.x < 0 and abs(vel.x) > abs(vel.y):
		facing = "left"
	elif vel.y > 0 and abs(vel.y) > abs(vel.x):
		facing = "down"
	elif vel.y < 0 and abs(vel.y) > abs(vel.x):
		facing = "up"

func get_anim_frame():
	var cur_anim = $anim.get_animation($anim.current_animation)
	var cur_frame = int($anim.current_animation_position / cur_anim.step)
	return cur_frame

func look_at(point):
	var dir = point - get_position()
	if dir.x > 0 and abs(dir.x) > abs(dir.y):
		facing = "right"
	elif dir.x < 0 and abs(dir.x) > abs(dir.y):
		facing = "left"
	elif dir.y > 0 and abs(dir.y) > abs(dir.x):
		facing = "down"
	elif dir.y < 0 and abs(dir.y) > abs(dir.x):
		facing = "up"
		
func play_anim(action, face = true):
	if !facing or !anims:
		print("no anims/facing...")
		init()
	var anim = get_node("anim")
	var a 
	if face:
		a = anims[facing][action]
	else:
		a = action
	if anim.get_current_animation() != a:
		anim.play(a)

func add_anim(action):
	anims["left"][action] = action + "_left"
	anims["right"][action] = action + "_right"
	anims["down"][action] = action + "_down"
	anims["up"][action] = action + "_up"
	anims["up_left"][action] = action + "_up_left"
	anims["up_right"][action] = action + "_up_right"
	anims["down_left"][action] = action + "_down_left"
	anims["down_right"][action] = action + "_down_right"
