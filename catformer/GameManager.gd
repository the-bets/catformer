extends Node

var current_level = 1

signal level_changed(new_level)

func _ready():
	call_deferred("load_current_level")

func load_current_level():
	var level_data: LevelData
	
	match current_level:
		1:
			level_data = LevelLoader.create_level_1()
		2:
			level_data = LevelLoader.create_level_2()
		_:
			# Generate random levels beyond level 2
			level_data = LevelLoader.create_random_level(current_level)
	
	print("Level data created successfully: ", level_data)
	
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
