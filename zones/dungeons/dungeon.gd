# each floor in a dungeon is an area.
# there will be other areas generated like shops, and doors will be placed in the main area leading to them


extends "res://zones/zone.gd"

onready var area_scn = "res://zones/area.tscn"
onready var tileset = "res://zones/tilesets/original_tiles.tres"
onready var generator_script = "res://src/dungeon_generator.gd"
onready var astar_script = "res://src/astar.gd"
onready var loc_script = "res://src/location.gd"
onready var enemy_scene = "res://actors/npcs/enemies/enemy.tscn"
var generator

onready var floor_number = 1
onready var floors = []

func _ready():
	#first thing it needs to do is build the dungeon area
		#gen rooms
		#pack rooms
		#place doors or halls
	#then place enemies, items, level exit (sub-areas?)
	initialize()
	# place enemies
	set_active_area("floor_1", "player_start", "down")
	place_enemies(active_area)
	

func initialize():
	print("entering")
	generator = load(generator_script).new(100, 100)
	print("entering genfloor")
	gen_floor()
	.initialize()
	pass

func place_enemies(area):
	var enemy
	var rooms = generator.get_rooms()
	for i in range(1, rooms.size()):
		if rooms[i].size_class == "medium":
			enemy = area.new_enemy()
			enemy.set_position(rooms[i].get_center())
		elif rooms[i].size_class == "large":
			enemy = area.new_enemy()
			enemy.set_position(rooms[i].get_center())
	
func print_map(grid):
	for row in grid:
		print(String(row))
		global.cprint(String(row))

func print_tilemap(tmap):
	print(String(tmap.get_used_cells()))
	global.cprint(String(tmap.get_used_cells()))

# Creates a complete dungeon "floor"
func gen_floor():
	# declare some vars
	var rooms = []
	# setup the area scene
	var new_floor = load(area_scn).instance()
	new_floor.name = "floor_" + String(floor_number)
	floor_number += 1
	var map_node = Node2D.new()
	map_node.name = "map"
	map_node.set_script(load(astar_script))
	new_floor.add_child(map_node)
	new_floor.move_child(map_node, 0)
	# create first tilemap layer
	map_node.add_child(new_tilemap("layer_1"))
	print("generator is building map...")
	generator.build_map()
	place_tiles(map_node.get_node("layer_1"), generator.get_map())
	rooms = generator.get_rooms()
	# create location to place player
	var player_pos = rooms[0].get_center()
	new_floor.get_node("locs").add_child(new_loc(player_pos, "player_start"))
	# add enemies to the rest of the rooms
	#place_enemies(new_floor)
	# finally add the floor to areas
	$areas.add_child(new_floor)
	return new_floor

func new_loc(_pos, _name):
	var loc = Position2D.new()
	loc.name = _name
	loc.set_position(_pos)
	loc.set_script(load(loc_script))
	return loc

func place_tiles(tmap, grid):
	for row in range(0, grid.size()):
		for col in range(0, grid[0].size()):
			tmap.set_cell(col, row, grid[row][col])
	#print_tilemap(tmap)
	
func new_tilemap(_name):
	var tmap = TileMap.new()
	tmap.name = _name
	tmap.set_tileset(load(tileset))
	tmap._update_dirty_quadrants()
	tmap.set_collision_layer_bit(0, true) #terrain
	return tmap