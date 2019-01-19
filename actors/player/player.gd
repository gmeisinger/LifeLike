extends "res://actors/actor.gd"

signal open_game_menu
signal open_player_menu

const ATTACK_SPEED = 1.0
const INVINCIBLE_TIME = 0.3
const DODGE_FORCE = 200.0

var cooldowns = {
	"dodge" : 0.5
	}

enum {WALKING, IDLE, ATTACKING, RECOILING, DODGING}
var state = IDLE
var input_held = null
var targets = []
var shape_adjust
var weapon = false
var input_locked = false
var click_target
var invincible = false
var invincible_timer = 0

#player has more animations
onready var anims_up_left = {
	walk = "walk_up_left",
	idle = "idle_up_left",
	hooray = "idle_up_left"
	}
onready var anims_up_right = {
	walk = "walk_up_right",
	idle = "idle_up_right",
	hooray = "idle_up_right"
	}
onready var anims_down_left = {
	walk = "walk_down_left",
	idle = "idle_down_left",
	hooray = "idle_down_left"
	}
onready var anims_down_right = {
	walk = "walk_down_right",
	idle = "idle_down_right",
	hooray = "idle_down_right"
	}

func _ready():
	$hitbox.set_position(Vector2(0, POS_ADJUSTMENT))
	anims["up_left"] = anims_up_left
	anims["up_right"] = anims_up_right
	anims["down_left"] = anims_down_left
	anims["down_right"] = anims_down_right
	add_anim("attack")
	add_anim("dodge")
	connect("open_dialog", global.get_cur_scene().get_node("ui/dialog"), "open")
	#set_pause_mode(Node.PAUSE_MODE_STOP)
	shape_adjust = Vector2(get_node("interact/shape").get_shape().get_radius(), get_node("interact/shape").get_shape().get_height()/2)
	pass

func _input(event):
	if global.check_input(event.as_text()):
		# Menu
		if event.is_action_pressed("player_game_menu"):
			emit_signal("open_game_menu")
		elif event.is_action_pressed("player_char_menu"):
			emit_signal("open_player_menu")

func handle_input():
	#RELEASE
	if input_held and Input.is_action_just_released(input_held):
		input_held = null
	#MOVEMENT
	if Input.is_action_pressed("ui_up"):
		vel.y -= WALK_FORCE
	if Input.is_action_pressed("ui_down"):
		vel.y += WALK_FORCE
	if Input.is_action_pressed("ui_left"):
		vel.x -= WALK_FORCE
	if Input.is_action_pressed("ui_right"):
		vel.x += WALK_FORCE
	#ACTIONS
	if Input.is_action_just_pressed("player_attack"):
		click_target = get_global_mouse_position()
		#vel = Vector2(0,0)
		state = ATTACKING
		#input_locked = true
	elif Input.is_action_just_pressed("player_dodge"):
		vel = vel.normalized() * DODGE_FORCE
		state = DODGING
		#input_locked = true
	elif Input.is_action_just_pressed("player_a") and !input_held:
		input_held = "player_a"
		if !targets.empty():
			targets[0].get_parent().interact()
	
	#max values
	if abs(vel.x) > MAX_SPEED:
		var s = sign(vel.x)
		#vel.x = MAX_SPEED * s
	if abs(vel.y) > MAX_SPEED:
		var s = sign(vel.y)
		#vel.y = MAX_SPEED * s
	#moving
	if vel.x or vel.y:
		moving = true
	else:
		moving = false

func update_state():
	match(state):
		IDLE:
			play_anim("idle")
			if vel.x or vel.y:
				state = WALKING
		WALKING:
			play_anim("walk")
			if !vel.x and !vel.y:
				state = IDLE
		ATTACKING:
			look_at(click_target)
			input_locked = true
			play_anim("attack")
			attack() 	
			#signal handles the switch to IDLE
		RECOILING:
			invincible = true
			if invincible_timer > INVINCIBLE_TIME:
				invincible = false
				state = IDLE
		DODGING:
			play_anim("dodge")
			invincible = true
			input_locked = true
			$hitbox/shape.disabled = true
			FRICTION = 1.0
			#signal handles switch to idle

func attack():
	var frame_num = get_anim_frame()
	if frame_num == 1 or frame_num == 2:
		$attacks.get_node(facing).disabled = false
	else:
		$attacks.get_node(facing).disabled = true

func update_facing():
	if vel.x > 0 and vel.y == 0:
		facing = "right"
	elif vel.x < 0 and vel.y == 0:
		facing = "left"
	elif vel.y > 0 and vel.x == 0:
		facing = "down"
	elif vel.y < 0 and vel.x == 0:
		facing = "up"
	elif vel.x > 0 and vel.y > 0:
		facing = "down_right"
	elif vel.x > 0 and vel.y < 0:
		facing = "up_right"
	elif vel.x < 0 and vel.y > 0:
		facing = "down_left"
	elif vel.x < 0 and vel.y < 0:
		facing = "up_left"

func update_shapes():
	#update weapon
	#$weapon.set_pos(facing)
	#update interact
	var interaction = get_node("interact/shape")
	match(facing):
		"left":
			interaction.set_position(Vector2(-shape_adjust.x, 0))
		"right":
			interaction.set_position(Vector2(shape_adjust.x, 0))
		"up":
			interaction.set_position(Vector2(0, -shape_adjust.y))
		"down":
			interaction.set_position(Vector2(0, shape_adjust.y))
		"up_left":
			interaction.set_position(Vector2(-shape_adjust.x/2, -shape_adjust.y/2))
		"up_right":
			interaction.set_position(Vector2(shape_adjust.x/2, -shape_adjust.y/2))
		"down_left":
			interaction.set_position(Vector2(-shape_adjust.x/2, shape_adjust.y/2))
		"down_right":
			interaction.set_position(Vector2(shape_adjust.x/2, shape_adjust.y/2))
			
func take_hit(enemy):
	var damage = 10.0
	if state == ATTACKING:
		damage = damage/2
	else:
		var vec = (get_position() - enemy.get_position()).normalized()
		vel = vec * WALK_FORCE * 30
	if !invincible:
		player_vars.stats["hp"] -= damage
	if player_vars.stats["hp"] <= 0:
		die()
	#$hp.value = stats["hp"]
	#$hp.visible = true
	state = RECOILING
	invincible = true		# technically redundant
	invincible_timer = 0	# technically NOT redundant (this must be set to zero when state is set)

func die():
	global.cprint("youre dead")

func _physics_process(delta):
	invincible_timer += delta
	if !input_locked:
		handle_input()
	update_shapes()
	update_state()
	._physics_process(delta)

func _on_interact_area_entered(area):
	targets.append(area)


func _on_interact_area_exited(area):
	targets.erase(area)


func _on_anim_animation_finished(anim_name):
	if anim_name.begins_with("attack"):
		state = IDLE
		input_locked = false
	elif anim_name.begins_with("dodge"):
		state = IDLE
		input_locked = false
		invincible = false
		$hitbox/shape.disabled = false
		FRICTION = 1.2
	pass # replace with function body


func _on_attacks_area_entered(area):
	var enemy = area.get_parent()
	if enemy.is_in_group("enemies"):
		area.get_parent().take_hit()
		global.cprint("player hit enemy")



func _on_hitbox_area_entered(area):
	global.cprint("enemy hit")
	var enemy = area.get_parent()
	if enemy.attacking:
		take_hit(enemy)

