extends "res://zones/zone.gd"

onready var start_msg = "Not again..."

func _ready():
	set_active_area("home", "door", "down")
	
	var guide = "Move with WSAD\nSPACE -- Interact\nSHIFT -- Dodge\nLEFT CLICK -- Attack"
	if player_vars.guide:
		player_vars.guide = false
		global.get_player().emit_signal("open_dialog", guide)
		yield($ui/dialog, "popup_hide")
	global.get_player().emit_signal("open_dialog", start_msg)
