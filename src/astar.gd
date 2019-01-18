extends Node2D

# You can only create an AStar node from code, not from the Scene tab
onready var astar_node = AStar.new()
onready var astar_node_free = AStar.new()
# The Tilemap node doesn't have clear bounds so we're defining the map's limits here
onready var maps = get_children()
onready var map_size = maps[0].get_used_rect().size

# The path start and end variables use setter methods
# You can find them at the bottom of the script
var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []

# get_used_cells_by_id is a method from the TileMap node
# here the id 0 corresponds to the grey tile, the obstacles
onready var _cell_size = maps[0].cell_size
onready var _half_cell_size = _cell_size / 2
var obstacles
var navs
var obstacle_ids
var nav_ids

func _ready():
	scan_ids()
	get_obstacles()
	get_navs()
	#var cells_list = astar_add_walkable_cells(obstacles)
	var nav_cells_list = astar_add_navigable_cells(navs)
	var walk_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(nav_cells_list)
	astar_connect_walkable_cells_free(walk_cells_list)
	pass

func scan_ids():
	obstacle_ids = []
	nav_ids = []
	for map in maps:
		var tset = map.get_tileset()
		var ids = tset.get_tiles_ids()
		for id in ids:
			if tset.tile_get_navigation_polygon(id) and !nav_ids.has(id):
				nav_ids.append(id)
			elif tset.tile_get_shape_count(id) and !obstacle_ids.has(id):
				obstacle_ids.append(id)

func get_obstacles():
	obstacles = []
	for map in maps:
		for id in obstacle_ids:
			var locs = map.get_used_cells_by_id(id)
			obstacles += locs

func get_navs():
	navs = []
	for map in maps:
		for id in nav_ids:
			var locs = map.get_used_cells_by_id(id)
			navs += locs
		
# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells(obstacles = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if !obstacles.has(point):
				points_array.append(point)
				# The AStar class references points with indices
				# Using a function to calculate the index from a point's coordinates
				# ensures we always get the same index with the same input point
				var point_index = calculate_point_index(point)
				# AStar works for both 2d and 3d, so we have to convert the point
				# coordinates from and to Vector3s
				astar_node_free.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array
	
func astar_add_navigable_cells(navs = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if point in obstacles:
				continue
			if navs.has(point) and !obstacles.has(point):
				points_array.append(point)
				# The AStar class references points with indices
				# Using a function to calculate the index from a point's coordinates
				# ensures we always get the same index with the same input point
				var point_index = calculate_point_index(point)
				# AStar works for both 2d and 3d, so we have to convert the point
				# coordinates from and to Vector3s
				astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array
	
# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce,
		# We connect the current point with it
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)

			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A
			# If you set this value to false, it becomes a one-way path
			# As we loop through all points we can set it to false
			astar_node.connect_points(point_index, point_relative_index, false)
			

# This is a variation of the method above
func astar_connect_walkable_cells_free(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)

				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node_free.has_point(point_relative_index):
					continue
				astar_node_free.connect_points(point_index, point_relative_index, true)


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func calculate_point_index(point):
	return point.x + map_size.x * point.y
	
func get_path(world_start, world_end, free):
	self.path_start_position = maps[0].world_to_map(world_start)
	self.path_end_position = maps[0].world_to_map(world_end)
	if free:
		_recalculate_path_free()
	else:
		_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = maps[0].map_to_world(Vector2(point.x, point.y)) + _half_cell_size
		path_world.append(point_world)
	return path_world


func _recalculate_path():
	#clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)

func _recalculate_path_free():
	#clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node_free.get_point_path(start_point_index, end_point_index)
	
# Setters for the start and end path values.
func _set_path_start_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	#set_cell(path_start_position.x, path_start_position.y, -1)
	#set_cell(value.x, value.y, 1)
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	#set_cell(path_start_position.x, path_start_position.y, -1)
	#set_cell(value.x, value.y, 2)
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()