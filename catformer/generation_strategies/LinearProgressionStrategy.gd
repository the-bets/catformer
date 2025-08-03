extends LevelGenerationStrategy
class_name LinearProgressionStrategy

# LinearProgressionStrategy - Creates levels with straightforward left-to-right progression
# Good for beginners, predictable difficulty curve

func generate_level(level_number: int, config: GameConfig) -> LevelData:
	var level = LevelData.new()
	level.level_number = level_number
	level.player_spawn_position = Vector2(100, 450)
	
	var platforms = []
	var current_pos = Vector2(100, 500)
	
	# Create starting platform
	var start_platform = _create_platform(current_pos, Color(0.6, 0.4, 0.2, 1))
	platforms.append(start_platform)
	
	# Generate platforms in a mostly linear progression
	var platform_count = _get_platform_count(config)
	var difficulty = _get_difficulty_for_level(level_number)
	
	for i in range(platform_count):
		var next_pos = _generate_next_linear_position(current_pos, difficulty, config)
		var platform_color = _get_platform_color(i, difficulty)
		var platform_size = _get_platform_size(difficulty, config)
		
		var platform = _create_platform(next_pos, platform_color, platform_size)
		platforms.append(platform)
		current_pos = next_pos
	
	# Place goal slightly ahead and above the last platform
	level.goal_position = _generate_goal_position(current_pos)
	level.platforms = platforms
	
	return level

func get_strategy_name() -> String:
	return "LinearProgression"

func get_difficulty_multiplier() -> float:
	return 0.8  # Slightly easier than average

func _get_platform_count(config: GameConfig) -> int:
	var min_platforms = config.min_platforms_per_level if config else 4
	var max_platforms = config.max_platforms_per_level if config else 7
	return randi_range(min_platforms, max_platforms)

func _get_difficulty_for_level(level_number: int) -> float:
	# Linear difficulty progression, capped at reasonable level
	return clamp(level_number * 0.1, 0.1, 0.8)

func _generate_next_linear_position(from_pos: Vector2, difficulty: float, config: GameConfig) -> Vector2:
	# Mostly move right, with some vertical variation
	var base_horizontal_step = 120 + (difficulty * 40)  # 120-160 pixels right
	var vertical_variation = 60 + (difficulty * 40)     # ±60-100 pixels vertical
	
	var horizontal_distance = base_horizontal_step + randi_range(-20, 20)
	var vertical_distance = randi_range(-int(vertical_variation), int(vertical_variation * 0.5))
	
	var next_pos = Vector2(
		from_pos.x + horizontal_distance,
		from_pos.y + vertical_distance
	)
	
	return _clamp_to_screen(next_pos)

func _get_platform_color(platform_index: int, difficulty: float) -> Color:
	# Color-code by difficulty
	if difficulty < 0.3:
		return Color(0.4, 0.8, 0.4, 1)  # Green - easy
	elif difficulty < 0.6:
		return Color(0.4, 0.6, 0.8, 1)  # Blue - medium
	else:
		return Color(0.8, 0.6, 0.4, 1)  # Orange - hard

func _get_platform_size(difficulty: float, config: GameConfig) -> Vector2:
	var base_size = config.platform_size if config else Vector2(128, 32)
	# Slightly smaller platforms as difficulty increases
	var size_multiplier = 1.0 - (difficulty * 0.2)  # 100% to 80% size
	return Vector2(base_size.x * size_multiplier, base_size.y)

func _generate_goal_position(last_platform_pos: Vector2) -> Vector2:
	# Goal positioned ahead and slightly above last platform
	var goal_pos = Vector2(
		last_platform_pos.x + randi_range(80, 120),
		last_platform_pos.y + randi_range(-60, -20)
	)
	return _clamp_to_screen(goal_pos)