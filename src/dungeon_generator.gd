# Procedural Dungeon Generator
# George Meisinger
# not finished

extends Node

#includes walls
const MIN_ROOM_WIDTH = 8
const MIN_ROOM_HEIGHT = 8
const MAX_ROOM_WIDTH = 20
const MAX_ROOM_HEIGHT = 20
const WALLS = [138,157,159,178,137,139,197,217,177,179,218,198]

var tile_ids = {
	"floor" : 158,
	"wall_bottom" : 138,
	"wall_right" : 157,
	"wall_left" : 159,
	"wall_top" : 178,
	"wall_top_left_inside" : 137,
	"wall_top_right_inside" : 139,
	"wall_bottom_right_outside" : 197,
	"wall_bottom_left_outside" : 217,
	"wall_bottom_left_inside" : 177,
	"wall_bottom_right_inside" : 179,
	"wall_top_right_outside" : 218,
	"wall_top_left_outside" : 198,
	}
	
onready var map = []
onready var rooms = []
#map dimensions in tiles
var map_width = 100
var map_height = 100

func _init(wid, hei):
	map_width = wid
	map_height = hei

func _ready():
	pass

func build_map():
	var max_wide = int(map_width / MAX_ROOM_WIDTH)
	var max_long = int(map_height / MAX_ROOM_HEIGHT)
	var desired_num_rooms = int(max_wide * max_long / 3) # dirty, just making sure it all fits
	var corners
	rooms = []
	if not map:
		init_grid()
	print("starting...")
	#place the first room
	var new_room = new_random_room()
	rooms.append(new_room)
	carve_room(new_room)
	#now keep getting spots for rooms
	print("placing rooms...")
	#while rooms.size() < desired_num_rooms:
	var num_attempts = 100
	for x in range(0, num_attempts):
		corners = find_corners(map)
		if corners.size() > 4:
			for corner in corners:
				if corner.x == 0 or corner.y == 0:
					corners.erase(corner)
		new_room = new_random_room()
		new_room.set_pos(corners[global.get_random_number(0,corners.size())])
		if check_overlap(new_room):
			rooms.append(new_room)
			carve_room(new_room)
	# we've placed all the rooms, now connect with doorways
	connect_rooms()
	print("...done")
	# print out some room stats?
	print("rooms: " + String(rooms.size()))
	global.cprint("rooms: " + String(rooms.size()))
	
func connect_rooms():
	var dead_end = false
	# first we find the neighbors
	for room in rooms:
		find_neighbors(room)
	# now we can start at a random room and begin connecting
	#var cur_room = rooms[global.get_random_number(0, rooms.size())]
	var cur_room = rooms[0]
	cur_room.connected = true
	var next_room = cur_room.neighbors[global.get_random_number(0, cur_room.neighbors.size())]
	while not verify_connected():
		if join(cur_room, next_room):
			print("join success.")
			next_room.connected = true
			cur_room.neighbors.erase(next_room)
			next_room.neighbors.erase(cur_room)
			cur_room = next_room
			if cur_room.neighbors.empty():
				dead_end = true
			else:
				next_room = cur_room.neighbors[global.get_random_number(0, cur_room.neighbors.size())]
		else:
			print("join fail.")
			cur_room.neighbors.erase(next_room)
			if cur_room.neighbors.empty():
				dead_end = true
			else:
				next_room = cur_room.neighbors[global.get_random_number(0, cur_room.neighbors.size())]
		if dead_end:
			#return
			# find a connected room with neighbors
			for room in rooms:
				if room.connected and room.neighbors.size() > 0:
					for neighbor in room.neighbors:
						if not neighbor.connected:
							cur_room = room
							next_room = neighbor
							break
	# try to connect stragglers
	for room in rooms:
		if not room.connected and room.neighbors.size() > 0:
			for neighbor in room.neighbors:
				if join(room, neighbor):
					room.connected = true
func join(room1, room2):
	var direction
	var border = []
	var start
	var end
	# from room1, where is room2?
	if room2.rect.position.x == room1.rect.end.x:
		#east
		direction = "east"
		start = room1.rect.position.y+1
		end = room1.rect.position.y + room1.rect.size.y-1
		for row in range(start, end):
			var pt = Vector2(room2.rect.position.x, row)
			if room2.rect.has_point(pt):
				border.append(pt)
		if border.size() < 6:
			return false
		else:
			start = border[int(border.size()/2)-2]
			carve_doorway(Vector2(start.x-1, start.y), true)
		
	elif room2.rect.position.y == room1.rect.end.y:
		#south
		direction = "south"
		start = room1.rect.position.x+1
		end = room1.rect.position.x + room1.rect.size.x-1
		for col in range(start, end):
			var pt = Vector2(col, room2.rect.position.y)
			if room2.rect.has_point(pt):
				border.append(pt)
		if border.size() < 6:
			return false
		else:
			start = border[int(border.size()/2)-2]
			carve_doorway(Vector2(start.x, start.y-1), false)	
	elif room2.rect.end.x == room1.rect.position.x:
		#west
		direction = "west"
		start = room1.rect.position.y+1
		end = room1.rect.position.y + room1.rect.size.y-1
		for row in range(start, end):
			var pt = Vector2(room2.rect.end.x, row)
			if room2.rect.has_point(pt):
				border.append(pt)
		if border.size() < 6:
			return false
		else:
			start = border[int(border.size()/2)-2]
			carve_doorway(Vector2(start.x, start.y), true)
	elif room2.rect.end.y == room1.rect.position.y:
		#north
		direction = "north"
		start = room1.rect.position.x+1
		end = room1.rect.position.x + room1.rect.size.x-1
		for col in range(start, end):
			var pt = Vector2(col, room2.rect.end.y)
			if room2.rect.has_point(pt):
				border.append(pt)
		if border.size() < 6:
			return false
		else:
			start = border[int(border.size()/2)-2]
			carve_doorway(Vector2(start.x, start.y), false)
	else:
		return false
	print("room1: " + String(room1.rect.position) + String(room1.rect.end))
	print("room2: " + String(room2.rect.position) + String(room2.rect.end))
	return true
	
func verify_connected():
	for room in rooms:
		if not room.connected:
			return false
	return true

func check_overlap(new_room):
	if new_room.rect.position.x + new_room.rect.size.x > map_width:
		return false
	if new_room.rect.position.y + new_room.rect.size.y > map_height:
		return false
	for room in rooms:
		if new_room.rect.intersects(room.rect):
			return false
	return true

func find_corners(grid):
	var corners = []
	for row in range(0, grid.size()):
		for col in range(0, grid[0].size()):
			if grid[row][col] == -1:
				#empty spot found, check if valid
				#corner cases first
				if row == 0:
					if WALLS.has(grid[row][col-1]):
						corners.append(Vector2(col,row)) 
				elif col == 0:
					if WALLS.has(grid[row-1][col]):
						corners.append(Vector2(col,row))
				else:
					if WALLS.has(grid[row][col-1]) and WALLS.has(grid[row-1][col]):
						corners.append(Vector2(col,row))
	return corners

func get_map():
	return map

func get_rooms():
	return rooms

func init_grid():
	map = new_grid(map_width, map_height)
		
func new_room(_size):
	var new_room = Room.new(_size, tile_ids)
	return new_room

func new_random_room():
	var _size = Vector2(global.get_random_number(MIN_ROOM_WIDTH, MAX_ROOM_WIDTH+1), global.get_random_number(MIN_ROOM_HEIGHT, MAX_ROOM_HEIGHT+1))
	var room = new_room(_size)
	return room
	
func place_room(room, _pos):
	room.set_pos(_pos)
	
func new_grid(wid, hei):
	var grid = []
	for row in range(0, hei):
		var new_row = []
		for col in range(0, wid):
			new_row.append(-1)
		grid.append(new_row)
	return grid

func carve_room(room):
	var start = room.get_pos()
	var size = room.size()
	var ids = room.get_grid()
	if not map:
		init_grid()
	for row in range(0, size.y):
		for col in range(0, size.x):
			map[start.y + row][start.x + col] = ids[row][col]

func carve_doorway(start, horz):
	print("carving doorway...")
	if horz:
		#carve horizontal hall
		map[start.y][start.x] = tile_ids["wall_bottom_left_inside"]
		map[start.y][start.x+1] = tile_ids["wall_bottom_right_inside"]
		map[start.y+1][start.x] = tile_ids["floor"]
		map[start.y+1][start.x+1] = tile_ids["floor"]
		map[start.y+2][start.x] = tile_ids["floor"]
		map[start.y+2][start.x+1] = tile_ids["floor"]
		map[start.y+3][start.x] = tile_ids["wall_top_left_inside"]
		map[start.y+3][start.x+1] = tile_ids["wall_top_right_inside"]
	else:
		#carve vertical hall
		map[start.y][start.x] = tile_ids["wall_top_right_inside"]
		map[start.y][start.x+1] = tile_ids["floor"]
		map[start.y][start.x+2] = tile_ids["floor"]
		map[start.y][start.x+3] = tile_ids["wall_top_left_inside"]
		map[start.y+1][start.x] = tile_ids["wall_bottom_right_inside"]
		map[start.y+1][start.x+1] = tile_ids["floor"]
		map[start.y+1][start.x+2] = tile_ids["floor"]
		map[start.y+1][start.x+3] = tile_ids["wall_bottom_left_inside"]

func fill_room(room):
	var rect = room.rect
	for row in range(rect.position.y, rect.position.y + rect.size.y):
		for col in range(rect.position.x, rect.position.x + rect.size.x):
			map[row][col] = -1

func find_neighbors(room):
	var potential_neighbors = []
	if room.rect.end.y < map_height-1:
		#check bottom
		for col in range(room.rect.position.x, room.rect.position.x + room.rect.size.x):
			if WALLS.has(map[room.rect.end.y+1][col]):
				potential_neighbors.append(Vector2(col, room.rect.end.y+1))
	if room.rect.end.x < map_width-1:
		#check right
		for row in range(room.rect.position.y, room.rect.position.y + room.rect.size.y):
			if WALLS.has(map[row][room.rect.end.x+1]):
				potential_neighbors.append(Vector2(room.rect.end.x+1, row))
	if room.rect.position.y > 0:
		#check top
		for col in range(room.rect.position.x, room.rect.position.x + room.rect.size.x):
			if WALLS.has(map[room.rect.position.y-1][col]):
				potential_neighbors.append(Vector2(col, room.rect.position.y-1))
	if room.rect.position.x > 0:
		#check left
		for row in range(room.rect.position.y, room.rect.position.y + room.rect.size.y):
			if WALLS.has(map[row][room.rect.position.x-1]):
				potential_neighbors.append(Vector2(room.rect.position.x-1, row))
	# now we need ot iterate over potential neighbor points
	# get the room it belongs to
	# add that room if not added
	for point in potential_neighbors:
		for other_room in rooms:
			if other_room.rect.has_point(point):
				if !room.neighbors.has(other_room):
					room.neighbors.append(other_room)

class Room:
	var rect = Rect2()
	var id_grid
	var tile_ids
	var connected = false # used when connecting rooms
	var neighbors = []
	var size_class
	
	func _init(_size, tids):
		rect.position = Vector2(0,0)
		rect.size = _size
		tile_ids = tids
		id_grid = new_grid(rect.size.x, rect.size.y)
		place_floors()
		place_corners()
		place_walls()
		var area = rect.get_area()
		if area < 150:
			size_class = "small"
		elif area < 250:
			size_class = "medium"
		else:
			size_class = "large"
	
	func add_neighbor(room):
		# first check to see if its a neighbor
		var valid = false
		var dest_rect = room.rect
		if rect.intersects(dest_rect):
			return false
	
	func get_grid():
		return id_grid
		
	func set_pos(_pos):
		rect.position = _pos
	
	func get_pos():
		return rect.position
		
	func size():
		return rect.size
	
	func new_grid(wid, hei):
		var grid = []
		for row in range(0, hei):
			var new_row = []
			for col in range(0, wid):
				new_row.append(-1)
			grid.append(new_row)
		return grid
	
	func place_floors():
		for row in range(1, rect.size.y-1):
			for col in range(1, rect.size.x-1):
				id_grid[row][col] = tile_ids["floor"]
	
	func place_corners():
		id_grid[0][0] = tile_ids["wall_top_left_outside"]
		id_grid[0][rect.size.x-1] = tile_ids["wall_top_right_outside"]
		id_grid[rect.size.y-1][0] = tile_ids["wall_bottom_left_outside"]
		id_grid[rect.size.y-1][rect.size.x-1] = tile_ids["wall_bottom_right_outside"]
	
	func place_walls():
		for col in range(1, rect.size.x-1):
			id_grid[0][col] = tile_ids["wall_top"]
			id_grid[rect.size.y-1][col] = tile_ids["wall_bottom"]
		for row in range(1, rect.size.y-1):
			id_grid[row][0] = tile_ids["wall_left"]
			id_grid[row][rect.size.x-1] = tile_ids["wall_right"]
	
	func get_center():
		var center = Vector2((rect.position.x + rect.size.x/2)*global.TILESIZE, (rect.position.y + rect.size.y/2) * global.TILESIZE)
		return center