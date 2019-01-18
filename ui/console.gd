extends Label

const MAX_LINES = 9

var entries = []

func _ready():
	pass

func _on_zone_console_add(msg):
	var text = msg + "\n" + get_text()
	set_text(text)
