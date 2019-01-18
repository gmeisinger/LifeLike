extends ProgressBar

func _ready():
	value = player_vars.stats["hp"]
	pass

func _process(delta):
	value = player_vars.stats["hp"]