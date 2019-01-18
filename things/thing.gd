extends KinematicBody2D

signal open_dialog
signal open_choice_dialog

export(String) var msg

func _ready():
	connect("open_dialog", global.get_cur_scene().get_node("ui/dialog"), "open")
	connect("open_choice_dialog", global.get_cur_scene().get_node("ui/choice_dialog"), "open")
	pass

func interact():
	emit_signal("dialog_open", get_class())
	pass