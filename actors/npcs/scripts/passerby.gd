extends "res://actors/npcs/npc.gd"

var exit

func set_exit(_exit):
	exit = _exit
	dest = _exit
	nav_on = true
	
func find_new_target():
	queue_free()

func _physics_process(delta):
	if state == IDLE:
		dest = exit
	._physics_process(delta)