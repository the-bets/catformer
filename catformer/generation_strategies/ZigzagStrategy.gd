extends LevelGenerationStrategy
class_name ZigzagStrategy

# ZigzagStrategy - Creates levels with back-and-forth movement patterns
# Requires more precise movement and planning from the player

func generate_level(level_number: int, config: GameConfig) -> LevelData:
	var level = LevelData.new()
	level.level_number = level_number
	level.player_spawn_position = Vector2(100, 450)
	
	var platforms = []
	var current_pos = Vector2(100, 500)
	
	# Create starting platform
	var start_platform = _create_platform(current_pos, Color(0.6, 0.4, 0.2, 1))
	platforms.append(start_platform)
	
	# Generate zigzag pattern
	var platform_count = _get_platform_count(config)
	var difficulty = _get_difficulty_for_level(level_number)
	var direction = 1  # 1 = right, -1 = left
	var segment_length = 0
	var max_segment_length = 2 + int(difficulty * 2)  # 2-4 platforms per segment
	
	for i in range(platform_count):
		var next_pos = _generate_next_zigzag_position(current_pos, direction, difficulty, config)
		var platform_color = _get_platform_color_for_direction(direction)
		var platform_size = _get_platform_size(difficulty, config)
		
		var platform = _create_platform(next_pos, platform_color, platform_size)
		platforms.append(platform)
		current_pos = next_pos
		
		# Check if we should switch direction
		segment_length += 1
		if segment_length >= max_segment_length or _should_switch_direction(current_pos):
			direction *= -1  # Switch direction
			segment_length = 0
			max_segment_length = randi_range(2, 3 + int(difficulty * 2))
	
	# Place goal at the end
	level.goal_position = _generate_goal_position(current_pos)
	level.platforms = platforms
	
	return level

func get_strategy_name() -> String:
	return "Zigzag"

func get_difficulty_multiplier() -> float:
	return 1.2  # Slightly harder than average

func _get_platform_count(config: GameConfig) -> int:
	var min_platforms = config.min_platforms_per_level if config else 5
	var max_platforms = config.max_platforms_per_level if config else 8
	return randi_range(min_platforms, max_platforms)

func _get_difficulty_for_level(level_number: int) -> float:
	return clamp(level_number * 0.12, 0.2, 0.9)

func _generate_next_zigzag_position(from_pos: Vector2, direction: int, difficulty: float, config: GameConfig) -> Vector2:
	# Move in the specified direction with some height variation
	var horizontal_distance = (100 + randi_range(0, 50)) * direction  # 100-150 pixels
	var vertical_distance = randi_range(-80, 40)  # Favor going up slightly
	
	# Add difficulty scaling
	horizontal_distance += int(difficulty * 30) * direction
	
	var next_pos = Vector2(
		from_pos.x + horizontal_distance,
		from_pos.y + vertical_distance
	)
	
	return _clamp_to_screen(next_pos)

func _should_switch_direction(current_pos: Vector2) -> bool:
	# Switch direction if we're getting too close to screen edges
	return current_pos.x < 200 or current_pos.x > 600

func _get_platform_color_for_direction(direction: int) -> Color:
	if direction > 0:
		return Color(0.4, 0.8, 0.6, 1)  # Green-cyan for rightward
	else:
		return Color(0.8, 0.4, 0.6, 1)  # Pink-red for leftward

func _get_platform_size(difficulty: float, config: GameConfig) -> Vector2:
	var base_size = config.platform_size if config else Vector2(128, 32)
	# Slightly smaller platforms as difficulty increases
	var size_multiplier = 1.0 - (difficulty * 0.15)
	return Vector2(base_size.x * size_multiplier, base_size.y)

func _generate_goal_position(last_platform_pos: Vector2) -> Vector2:
	var goal_pos = Vector2(
		last_platform_pos.x + randi_range(-50, 50),  # Could be left or right
		last_platform_pos.y + randi_range(-80, -30)  # Always above
	)
	return _clamp_to_screen(goal_pos)