extends Position2D

export(bool) var spawn = false
export(bool) var available = true
export(int) var max_visitors = 3
export(int) var max_random = 64

onready var num_visitors = 0

func _ready():
	pass

func get_random_position():
	var rand_x = global.get_random_number(-max_random, max_random)
	var rand_y = global.get_random_number(-max_random, max_random)
	return get_position() + Vector2(rand_x, rand_y)
