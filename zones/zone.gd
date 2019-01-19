extends Node2D

signal console_add
signal area_changed

onready var camera = global.search_node("camera")
onready var player = get_node("player")

onready var areas = {}
var active_area
var active_id
var active_locs

func _ready():
	if $areas.get_child_count() > 0:
		initialize()

func initialize():
	active_id = $areas.get_child(0).name
	for area in $areas.get_children():
		areas[area.name] = area
		$areas.remove_child(area)
	active_area = areas[active_id]
	$areas.add_child(active_area)
	remove_child(player)
	active_area.add_object(player)
	active_locs = active_area.get_node("locs").get_children()

func check_camera():
	var cur_map = active_area.get_node("map")
	var tilesize = cur_map._cell_size
	camera.limit_left = 0
	camera.limit_top = -64
	camera.limit_right = cur_map.map_size.x * tilesize.x
	camera.limit_bottom = cur_map.map_size.y * tilesize.y
	var min_values = get_viewport().get_visible_rect().size
	if min_values.x > camera.limit_right:
		camera.limit_left = -1000000
		camera.limit_right = 1000000
	if min_values.y > camera.limit_bottom:
		camera.limit_top = -1000000
		camera.limit_bottom = 1000000
	camera.align()

func set_active_area(area, loc, face):
	#save player state
	player = active_area.remove_player()
	#save area state
	areas[active_id] = active_area
	#remove old area
	$areas.remove_child(active_area)
	#load new area
	active_id = area
	active_area = areas[active_id]
	#add it
	$areas.add_child(active_area)
	#add player
	active_area.add_object(player)
	active_locs = active_area.get_node("locs").get_children()
	connect_objects()
	var new_loc = find_location(loc)
	player.set_position(new_loc.get_position())
	player.facing = face
	check_camera()

func connect_objects():
	for obj in active_area.get_node("objects").get_children():
		obj.connect("open_dialog", $ui/dialog, "open")
		obj.connect("open_choice_dialog", $ui/choice_dialog, "open")
		
func connect_obj(obj):
	obj.connect("open_dialog", $ui/dialog, "open")
	obj.connect("open_choice_dialog", $ui/choice_dialog, "open")

func find_location(loc_name):
	var pos2d = active_area.find_location(loc_name)
	return pos2d

func update_time():
	global.time = 0

func _process(delta):
	global.time += delta
	update_time()