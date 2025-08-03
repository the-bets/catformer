class_name LevelFactory
extends RefCounted

# LevelFactory - Centralized level creation using Factory Pattern
# Provides clean separation between level types and creation logic

enum LevelType {
	TUTORIAL,
	STANDARD,
	CHALLENGE,
	RANDOM,
	CUSTOM
}

# Factory method - main entry point for level creation
static func create_level(level_number: int, type: LevelType = LevelType.STANDARD) -> LevelData:
	var level_data: LevelData
	
	match type:
		LevelType.TUTORIAL:
			level_data = _create_tutorial_level(level_number)
		LevelType.STANDARD:
			level_data = _create_standard_level(level_number)
		LevelType.CHALLENGE:
			level_data = _create_challenge_level(level_number)
		LevelType.RANDOM:
			level_data = _create_random_level(level_number)
		LevelType.CUSTOM:
			level_data = _create_custom_level(level_number)
		_:
			level_data = _create_standard_level(level_number)
	
	# Emit creation event
	var level_type_string = _get_level_type_string(type)
	var difficulty = get_level_difficulty(type, level_number)
	GameEventBus.emit_level_created(level_data, level_type_string, difficulty)
	
	return level_data

# Determine level type based on level number and progression
static func get_level_type_for_number(level_number: int) -> LevelType:
	var config = GameConfig.current
	var tutorial_count = config.tutorial_levels_count if config else 1
	var standard_count = config.standard_levels_count if config else 4
	var challenge_frequency = config.challenge_level_frequency if config else 5
	
	if level_number <= tutorial_count:
		return LevelType.TUTORIAL
	elif level_number <= tutorial_count + standard_count:
		return LevelType.STANDARD
	else:
		# After tutorial and standard levels, alternate between challenge and random
		if level_number % challenge_frequency == 0:
			return LevelType.CHALLENGE
		else:
			return LevelType.RANDOM

# Tutorial levels - simple, teach basic mechanics
static func _create_tutorial_level(level_number: int) -> LevelData:
	var level = LevelData.new()
	level.level_number = level_number
	level.player_spawn_position = Vector2(100, 450)
	level.goal_position = Vector2(700, 300)
	
	# Simple straight-line progression
	var platforms = []
	
	# Starting platform
	var start_platform = PlatformData.new()
	start_platform.position = Vector2(100, 500)
	start_platform.color = Color(0.6, 0.4, 0.2, 1)
	start_platform.size = Vector2(128, 32)
	platforms.append(start_platform)
	
	# Easy stepping stones
	var step_positions = [Vector2(250, 450), Vector2(400, 400), Vector2(550, 350)]
	for pos in step_positions:
		var platform = PlatformData.new()
		platform.position = pos
		platform.color = Color(0.4, 0.8, 0.4, 1)
		platform.size = Vector2(128, 32)
		platforms.append(platform)
	
	level.platforms = platforms
	return level

# Standard levels - hand-crafted, balanced difficulty
static func _create_standard_level(level_number: int) -> LevelData:
	match level_number:
		2:
			return _create_standard_level_2()
		3:
			return _create_standard_level_3()
		4:
			return _create_standard_level_4()
		5:
			return _create_standard_level_5()
		_:
			# Fallback to random for unknown standard levels
			return _create_random_level(level_number)

static func _create_standard_level_2() -> LevelData:
	var level = LevelData.new()
	level.level_number = 2
	level.player_spawn_position = Vector2(100, 500)
	level.goal_position = Vector2(650, 150)
	
	var platforms = []
	
	# Starting ground
	var ground = PlatformData.new()
	ground.position = Vector2(100, 550)
	ground.color = Color(0.6, 0.4, 0.2, 1)
	ground.size = Vector2(128, 32)
	platforms.append(ground)
	
	# More challenging layout
	var platform_configs = [
		{"pos": Vector2(300, 450), "size": Vector2(128, 32)},
		{"pos": Vector2(150, 350), "size": Vector2(128, 32)},
		{"pos": Vector2(500, 300), "size": Vector2(128, 32)},
		{"pos": Vector2(350, 200), "size": Vector2(128, 32)}
	]
	
	for config in platform_configs:
		var platform = PlatformData.new()
		platform.position = config.pos
		platform.color = Color(0.4, 0.8, 0.4, 1)
		platform.size = config.size
		platforms.append(platform)
	
	level.platforms = platforms
	return level

static func _create_standard_level_3() -> LevelData:
	var level = LevelData.new()
	level.level_number = 3
	level.player_spawn_position = Vector2(50, 500)
	level.goal_position = Vector2(750, 200)
	
	var platforms = []
	
	# Create a zigzag pattern
	var platform_positions = [
		Vector2(50, 550),   # Start
		Vector2(200, 480),  # Up-right
		Vector2(100, 400),  # Back-left higher
		Vector2(350, 380),  # Far right
		Vector2(250, 300),  # Back left
		Vector2(500, 280),  # Right again
		Vector2(650, 250)   # Final approach
	]
	
	for i in range(platform_positions.size()):
		var platform = PlatformData.new()
		platform.position = platform_positions[i]
		platform.color = Color(0.4, 0.8, 0.4, 1) if i > 0 else Color(0.6, 0.4, 0.2, 1)
		platform.size = Vector2(120, 32)
		platforms.append(platform)
	
	level.platforms = platforms
	return level

static func _create_standard_level_4() -> LevelData:
	var level = LevelData.new()
	level.level_number = 4
	level.player_spawn_position = Vector2(100, 500)
	level.goal_position = Vector2(700, 150)
	
	var platforms = []
	
	# Start platform
	var start = PlatformData.new()
	start.position = Vector2(100, 550)
	start.color = Color(0.6, 0.4, 0.2, 1)
	start.size = Vector2(128, 32)
	platforms.append(start)
	
	# Create multiple paths - player can choose route
	var left_path = [Vector2(200, 450), Vector2(150, 350), Vector2(250, 250)]
	var right_path = [Vector2(300, 480), Vector2(450, 420), Vector2(550, 300)]
	var convergence = Vector2(600, 200)
	
	# Add left path
	for pos in left_path:
		var platform = PlatformData.new()
		platform.position = pos
		platform.color = Color(0.4, 0.8, 0.4, 1)
		platform.size = Vector2(100, 32)
		platforms.append(platform)
	
	# Add right path
	for pos in right_path:
		var platform = PlatformData.new()
		platform.position = pos
		platform.color = Color(0.4, 0.8, 0.4, 1)
		platform.size = Vector2(100, 32)
		platforms.append(platform)
	
	# Convergence platform
	var final_platform = PlatformData.new()
	final_platform.position = convergence
	final_platform.color = Color(0.8, 0.6, 0.4, 1)
	final_platform.size = Vector2(128, 32)
	platforms.append(final_platform)
	
	level.platforms = platforms
	return level

static func _create_standard_level_5() -> LevelData:
	var level = LevelData.new()
	level.level_number = 5
	level.player_spawn_position = Vector2(100, 500)
	level.goal_position = Vector2(650, 100)
	
	var platforms = []
	
	# Ascending staircase with gaps
	var base_y = 550
	var step_height = 60
	var step_width = 120
	
	for i in range(7):
		var platform = PlatformData.new()
		platform.position = Vector2(100 + i * step_width, base_y - i * step_height)
		platform.color = Color(0.6, 0.4, 0.2, 1) if i == 0 else Color(0.4, 0.8, 0.4, 1)
		platform.size = Vector2(100, 32)
		platforms.append(platform)
	
	level.platforms = platforms
	return level

# Challenge levels - difficult, test player skills
static func _create_challenge_level(level_number: int) -> LevelData:
	var level = LevelData.new()
	level.level_number = level_number
	level.player_spawn_position = Vector2(100, 500)
	level.goal_position = Vector2(700, 100)
	
	var platforms = []
	var config = GameConfig.current
	
	# Challenge characteristics: smaller platforms, larger gaps, precise timing
	var platform_count = 8
	var current_pos = Vector2(100, 550)  # Start position
	
	# Start platform
	var start_platform = PlatformData.new()
	start_platform.position = current_pos
	start_platform.color = Color(0.6, 0.4, 0.2, 1)
	start_platform.size = Vector2(128, 32)
	platforms.append(start_platform)
	
	# Generate challenging platforms with tight tolerances
	var gap_multiplier = config.challenge_gap_multiplier if config else 0.9
	var size_multiplier = config.challenge_platform_size_multiplier if config else 0.8
	
	for i in range(platform_count):
		var max_horizontal = config.max_horizontal_jump * gap_multiplier if config else 110.0
		var max_vertical_up = config.max_vertical_jump_up * 0.8 if config else 70.0
		
		var horizontal_distance = randi_range(int(max_horizontal * 0.7), int(max_horizontal))
		var vertical_distance = randi_range(-int(max_vertical_up), 30)  # Mostly upward
		
		var next_pos = Vector2(
			current_pos.x + horizontal_distance,
			current_pos.y + vertical_distance
		)
		
		# Keep on screen with tighter bounds
		next_pos.x = clamp(next_pos.x, 150, 700)
		next_pos.y = clamp(next_pos.y, 100, 500)
		
		var platform = PlatformData.new()
		platform.position = next_pos
		platform.color = Color(0.8, 0.4, 0.4, 1)  # Red for danger
		var base_size = config.platform_size if config else Vector2(128, 32)
		platform.size = Vector2(base_size.x * size_multiplier, base_size.y)
		platforms.append(platform)
		
		current_pos = next_pos
	
	level.platforms = platforms
	return level

# Random levels - procedurally generated using strategy pattern
static func _create_random_level(level_number: int) -> LevelData:
	# Fallback to LevelLoader for now to avoid dependency issues
	return LevelLoader.create_random_level(level_number)

# Custom levels - placeholder for user-generated or special levels
static func _create_custom_level(level_number: int) -> LevelData:
	# For now, fallback to random. Later this could load from files or user data
	var level = _create_random_level(level_number)
	# Mark as custom for potential special handling
	level.level_number = level_number
	return level

# Utility method to create a platform with common defaults
static func _create_platform(position: Vector2, color: Color = Color.WHITE, size: Vector2 = Vector2(128, 32)) -> PlatformData:
	var platform = PlatformData.new()
	platform.position = position
	platform.color = color
	platform.size = size
	return platform

# Get level difficulty estimate (0.0 = easy, 1.0 = very hard)
static func get_level_difficulty(level_type: LevelType, level_number: int) -> float:
	match level_type:
		LevelType.TUTORIAL:
			return 0.1
		LevelType.STANDARD:
			return clamp(level_number * 0.15, 0.2, 0.7)
		LevelType.CHALLENGE:
			return clamp(0.8 + (level_number - 5) * 0.05, 0.8, 1.0)
		LevelType.RANDOM:
			return clamp((level_number - 5) * 0.1, 0.3, 0.9)
		LevelType.CUSTOM:
			return 0.5  # Unknown difficulty
		_:
			return 0.5

# Helper function to convert LevelType enum to string
static func _get_level_type_string(type: LevelType) -> String:
	match type:
		LevelType.TUTORIAL:
			return "TUTORIAL"
		LevelType.STANDARD:
			return "STANDARD"
		LevelType.CHALLENGE:
			return "CHALLENGE"
		LevelType.RANDOM:
			return "RANDOM"
		LevelType.CUSTOM:
			return "CUSTOM"
		_:
			return "UNKNOWN"