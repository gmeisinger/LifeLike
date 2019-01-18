extends Node2D

onready var npc_scene = preload("res://actors/npcs/npc.tscn")
onready var enemy_scene = preload("res://actors/npcs/enemies/enemy.tscn")
onready var passerby_script = preload("res://actors/npcs/scripts/passerby.gd")
onready var nav_script = preload("res://src/astar.gd")

onready var spawn_timer = 0
onready var spawn_count = 0

onready var map = get_child(0)
onready var spawns = []

#Descriptors for area behavior
export(bool) var outside = false
export(bool) var public = false
export(bool) var hostile = false

func _ready():
	if not has_node("map"):
		var map_node = Node2D.new()
		map_node.name = "map"
		add_child(map_node)
	$map.set_script(nav_script)
	for loc in $locs.get_children():
		if loc.spawn:
			spawns.append(loc)

func find_location(loc_name):
	var pos2d = $locs.get_node(loc_name)
	return pos2d

func new_npc(script = null):
	var new_npc = npc_scene.instance()
	add_object(new_npc)
	global.get_cur_scene().connect_obj(new_npc)
	if script:
		new_npc.set_script(script)
	return new_npc
	
func new_enemy():
	var new_enemy = enemy_scene.instance()
	add_object(new_enemy)
	global.get_cur_scene().connect_obj(new_enemy)
	return new_enemy

func add_object(obj):
	$objects.add_child(obj)

func remove_player():
	var p = $objects/player
	if p:
		$objects.remove_child(p)
	return p
	
# Spawning npcs




func _on_npc_arrived_at_dest(deleted_npc):
	#deleted_npc.queue_free()
	spawn_count -= 1
	pass