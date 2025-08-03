extends Node2D

@export var level_data: LevelData
var platform_scene = preload("res://Platform.tscn")
var goal_scene = preload("res://Goal.tscn")

signal level_completed

func _ready():
	pass

func load_level(data: LevelData):
	if not data:
		print("Error: LevelData is null!")
		return
		
	level_data = data
	
	var player = $Player
	if not player:
		print("Error: Player node not found!")
		return
		
	if player.has_method("set_spawn_position"):
		player.set_spawn_position(data.player_spawn_position)
	else:
		player.global_position = data.player_spawn_position
	
	# Defer the platform and goal creation to avoid physics query conflicts
	call_deferred("_create_level_objects", data)
	
	var level_label = $UI/LevelLabel
	level_label.text = "Level " + str(data.level_number)
	level_label.add_theme_font_size_override("font_size", Constants.LEVEL_LABEL_FONT_SIZE)

func _create_level_objects(data: LevelData):
	# Clear existing platforms
	var platforms_node = $Platforms
	for child in platforms_node.get_children():
		child.queue_free()
	
	# Clear existing goals
	var existing_goals = get_children().filter(func(child): return child is Goal)
	for goal in existing_goals:
		goal.queue_free()
	
	for platform_data in data.platforms:
		var platform = platform_scene.instantiate()
		platform.global_position = platform_data.position
		platform.platform_color = platform_data.color
		platform.platform_size = platform_data.size
		platforms_node.add_child(platform)
	
	var goal = goal_scene.instantiate()
	goal.global_position = data.goal_position
	add_child(goal)
	print("Connecting goal signal...")
	goal.goal_reached.connect(_on_goal_reached)
	print("Goal created at position: ", data.goal_position)
	print("Goal children: ", goal.get_children())

func _on_goal_reached(_body):
	print("Level completed! Moving to next level...")
	level_completed.emit()
