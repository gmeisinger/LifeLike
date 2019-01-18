# Tileset helper script
# George Meisinger
# 2018
# github.com/gmeisinger

# This script will take in a texture and
# return a tileset resource

# brainstorm:
	# read json
	# set tilesize, margin
	# create sprite nodes
		# if flagged, create staticbody2d node
		# and polygon using sprite

extends Node

var data
var texture_path
var margin = Vector2()
var tilesize = Vector2()

# Create 

# Functions below add data to an existing tile

# Helper functions

func getFileName(_path):
	var _fileName = _path.substr(_path.find_last("/")+1, _path.length() - _path.find_last("/")-1)
	var _dotPos = _fileName.find_last(".")
	if _dotPos != -1:
		_fileName = _fileName.substr(0,_dotPos)
	return _fileName
	
func read_json(_path):
	var file = File.new()
	if file.open(_path, file.READ) != OK:
		printerr("Failed to load "+_path)
	var text = file.get_as_text()
	var dict = JSON.parse(text).result
	if !dict:
		printerr("Invalid json data in "+_path)
	file.close()
	return dict
	