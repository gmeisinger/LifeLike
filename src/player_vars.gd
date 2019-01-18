extends Node

const MAX_HP = 100.0

var player_inventory = []
var player_knowledge = []
var player_dancing = false
var guide = true
var choice_dialog = null
var follower = null
var stats = {
	hp = 100.0,
	strength = 10,
	speed = 10,
	endurance = 10
	}

func _ready():
	pass

func dismiss_follower():
	if follower:
		follower.following = false
		follower = null
		
func set_follower(_follower):
	if follower:
		dismiss_follower()
	follower = _follower