extends PopupPanel

const MAX_LENGTH = 140

onready var screen = get_tree().get_root().size
onready var label = get_node("text")
var rect
var sz
var pos

var lines
var visible_lines
var lines_read
var lines_unread
var done

func _ready():
	#size
	sz = Vector2(screen.x/2, screen.y/4)
	pos = Vector2(screen.x/4,screen.y - screen.y/3)
	label.set_lines_skipped(0)
	done = false
	set_process_input(false)
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	pass

func _input(event):
	if event.is_action_pressed("ui_select") or event.is_action_pressed("player_a"):
		if done:
			get_tree().set_pause(false)
			set_process_input(false)
			hide()
		else:
			label.set_lines_skipped(lines_read)
			lines_read += visible_lines
			lines_unread = lines - lines_read
			if lines_unread < 1:
				done = true

func open(msg):
	if !is_visible():
		#split_msg(msg)
		done = false
		label.set_text(msg)
		label.set_lines_skipped(0)
		lines = label.get_line_count()
		visible_lines = int(sz.y / label.get_line_height())
		lines_read = visible_lines
		lines_unread = lines - lines_read
		if lines_unread < 1:
			done = true
		rect = Rect2(pos, sz)
		popup(rect)
		get_tree().set_pause(true)
		set_process_input(true)
	

func split_msg(msg, max_length):
	var words = msg.split(" ")
	var runningLength = 0
	var message = ""
	var messages = []
	for word in words:
		if message.empty():
			message = word
			runningLength += word.length()
		elif runningLength + word.length() < max_length:
			message = message +  " " + word
			runningLength += word.length()
		else:
			messages.append(message)
			message = word
			runningLength = word.length()
	if not message.empty():
		messages.append(message)
	return messages

