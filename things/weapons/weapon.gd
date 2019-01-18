extends KinematicBody2D

var pos_dict = {}

func _ready():
	pos_dict["left"] = PositionData.new(Vector2(-5.0,-17.0), -30, -1)
	pos_dict["right"] = PositionData.new(Vector2(0,-10.0), 40, 0)
	pos_dict["down"] = PositionData.new(Vector2(-10.0,-15.0), -20, 0)
	pos_dict["up"] = PositionData.new(Vector2(10.0,-14.0), 20, -1)
	pos_dict["down_left"] = PositionData.new(Vector2(-13.2,-16.4), -10, 0)
	pos_dict["down_right"] = PositionData.new(Vector2(-3.0,-8.0), -10, 0)
	pos_dict["up_left"] = PositionData.new(Vector2(5.0,-16.0), -10, -1)
	pos_dict["up_right"] = PositionData.new(Vector2(-5.0,-16.0), 20, -1)
	pass

func set_pos(face):
	var pos_data = pos_dict[face]
	set_position(pos_data.pos)
	set_global_rotation_degrees(pos_data.rotation)
	z_index = pos_data.z_pos

class PositionData:
	var pos
	var rotation
	var z_pos
	
	func _init(_pos, _rot, _z):
		pos = _pos
		rotation = _rot
		z_pos = _z