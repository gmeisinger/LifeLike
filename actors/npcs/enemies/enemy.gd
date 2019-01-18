extends "res://actors/npcs/npc.gd"

signal dying

const ATTACK_DIST = 2.0
const ATTACK_RANGE = 96.0
const TOO_CLOSE = 32.0
const MAX_HP = 100.0
const INVINCIBLE_TIME = 0.3 #half second after being hit
const ATTACK_COOLDOWN = 2.0

onready var is_visible = $visibility.is_on_screen()
var start_pos
var invincible = false
var invincible_timer = 0
var attack_timer = 0
var attack_target = null
var retreat_target = null
var attacking = false
var lefty = false
onready var face_lock = "down"
onready var attack_area = $interact


var stats = {
	hp = 100.0,
	strength = 10,
	speed = 10,
	endurance = 10
	}

func _ready():
	init()
	$hitbox.set_position(Vector2(0,POS_ADJUSTMENT))
	add_anim("attack")
	add_anim("hit")
	start_pos = get_position()
	free_nav = true
	$hp.value = stats["hp"]
	if global.get_random_number(0,2) == 0:
		lefty = true
	pass

func find_new_target():
	if is_visible:
		nav_on = true
		return global.get_player().get_position()
	else:
		if distance(start_pos) < WAIT_DIST:
			nav_on = false
		return start_pos

func update_state():
	match(state):
		IDLE:
			attacking = false
			attack_area.get_node("shape").disabled = true
			vel_mod = 1.0
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
			if distance(global.get_player().get_position()) < TOO_CLOSE:
				move_away(global.get_player().get_position())
			elif distance(global.get_player().get_position()) < ATTACK_RANGE:
				look_at(global.get_player().get_position())
				if attack_timer > ATTACK_COOLDOWN:
					state = ATTACKING
					face_lock = facing
					retreat_target = get_position()
					attack_target = global.get_player().get_position()
					dest = attack_target
				else:
					circle(global.get_player().get_position(), lefty)
			elif nav_on and dest:
				if distance(dest) < ARRIVE_DIST:
					#emit_signal("arrived_at_dest", self)
					dest = find_new_target()
				if dest:
					navigate(dest)	
					state = WALKING
				else:
					state = IDLE
		ATTACKING:
			attacking = true
			attack_area.get_node("shape").disabled = false
			facing = face_lock
			vel_mod = 4.0
			play_anim("attack")
			vel = (dest - get_position()).normalized() * (WALK_FORCE * vel_mod)
			if distance(attack_target) < ATTACK_DIST:
				dest = retreat_target
			elif distance(retreat_target) < ATTACK_DIST and dest == retreat_target:
				state = IDLE
				attack_timer = 0.0
		RECOILING:
			attacking = false
			attack_area.get_node("shape").disabled = true
			facing = face_lock
			play_anim("hit")
			if !invincible:
				state = IDLE
			

func take_hit():
	face_lock = facing
	var damage = 10.0
	if state == ATTACKING:
		damage = damage/2
		dest = retreat_target
		attack_timer = 0
	else:
		var vec = (get_position() - global.get_player().get_position()).normalized()
		vel = vec * WALK_FORCE * 30
	if !invincible:
		stats["hp"] -= damage
	if stats["hp"] <= 0:
		die()
	$hp.value = stats["hp"]
	$hp.visible = true
	state = RECOILING
	invincible = true
	invincible_timer = 0

func die():
	global.cprint("npc dying")
	emit_signal("dying")
	queue_free()

func interact():
	pass

func _physics_process(delta):
	if stats["hp"] <= 0:
		die()
	invincible_timer += delta
	if invincible_timer >= INVINCIBLE_TIME:
		invincible = false
	if stats["hp"] >= MAX_HP:
		stats["hp"] = MAX_HP
		$hp.visible = false
	if state != ATTACKING and state != RECOILING:
		attack_timer += delta
		dest = find_new_target()
	._physics_process(delta)

func _on_visibility_screen_entered():
	global.cprint(String(global.get_player().get_position()))
	is_visible = true
	nav_on = true
	dest = find_new_target()

func _on_visibility_screen_exited():
	global.cprint("exited")
	is_visible = false
	dest = find_new_target()
