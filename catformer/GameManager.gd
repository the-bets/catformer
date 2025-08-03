extends Node

var current_level = 1

signal level_changed(new_level)

func _ready():
	call_deferred("load_current_level")

func load_current_level():
	# Use LevelFactory to determine appropriate level type and create level
	var level_type = LevelFactory.get_level_type_for_number(current_level)
	var level_data = LevelFactory.create_level(current_level, level_type)
	
	var difficulty = LevelFactory.get_level_difficulty(level_type, current_level)
	print("Level ", current_level, " created successfully (Type: ", level_type, ", Difficulty: ", difficulty, ")")
	
	var level_scene = get_parent()
	
	if level_scene.has_method("load_level"):
		level_scene.load_level(level_data)
		if not level_scene.level_completed.is_connected(_on_level_completed):
			level_scene.level_completed.connect(_on_level_completed)

func next_level():
	current_level += 1
	load_current_level()
	level_changed.emit(current_level)

func _on_level_completed():
	next_level()
