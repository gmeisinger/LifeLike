extends Node

const TILESIZE = 64

# Input controller
onready var last_input = null

const ZONES = {
	loading = "res://ui/loading_screen.tscn",
	neighborhood = "res://zones/neighborhood/neighborhood.tscn",
	dungeon = "res://zones/dungeons/dungeon.tscn"
	}

var saved_scenes = {}

var current_scene
var interior = null
var time = 0
var day = true

# background loader vars
var loader
var wait_frames
var time_max = 100 # msec

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
func get_cur_scene():
	#current_scene = root.get_child(root.get_child_count() -1)
	return current_scene
	
func get_player():
	#returns the player in the current scene
	return current_scene.active_area.get_node("objects/player")
	
func get_random_number(from, to):
	randomize()
	return from + (randi() % (to - from))
	
		
func search_node(name, start = current_scene):
	return start.find_node(name)
	

	
func cprint(text):
	current_scene.emit_signal("console_add", text)

func check_input(event):
	if !last_input:
		last_input = event
		return true
	elif last_input == event:
		last_input = null
		return false
	else:
		last_input = event
		return true


# SCENE SWITCHING

func goto_scene(zone, dest_loc, face = "up"):
	var path = ZONES[zone]
	#if path:
	#	call_deferred("_deferred_goto_scene", path, dest_loc, face)
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		show_error()
		return
	set_process(true)
	call_deferred("_deferred_goto_scene")
	#current_scene.queue_free() # get rid of the old scene
	# start your "loading..." animation
	wait_frames = 1

func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return
	if wait_frames > 0: # wait for frames to let the "loading" animation show up
		wait_frames -= 1
		return
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread
		# poll your loader
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			#show_error()
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	current_scene.get_node("progress").value = progress
	# ...or update a progress animation?
#	var length = get_node("animation").get_current_animation_length()
	# Call this on a paused animation. Use "true" as the second argument to force the animation to update.
#	get_node("animation").seek(progress * length, true)
	pass

func set_new_scene(scene_resource):
	current_scene.queue_free()
	current_scene = scene_resource.instance()
	get_tree().get_root().add_child(current_scene)

func goto_title():
	call_deferred("_deferred_goto_scene", "res://ui/titlescreen.tscn")

func _deferred_goto_scene(path = ZONES["loading"]):
# Immediately free the current scene,
# there is no risk here.
	current_scene.free()
	# Load new scene.
	var s = ResourceLoader.load(path)
	# Instance the new scene.
	current_scene = s.instance()
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	# Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

func save_scene(scene = current_scene):
	pass
	
func load_scene(scene):
	pass