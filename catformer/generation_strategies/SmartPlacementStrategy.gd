extends LevelGenerationStrategy
class_name SmartPlacementStrategy

# SmartPlacementStrategy - Uses intelligent placement rules and validation
# Incorporates all the anti-overlap and traversability logic from LevelLoader

func generate_level(level_number: int, config: GameConfig) -> LevelData:
	var level = LevelData.new()
	level.level_number = level_number
	level.player_spawn_position = Vector2(100, 450)
	
	var platforms = []
	var current_pos = Vector2(100, 500)
	
	# Create starting platform
	var start_platform = _create_platform(current_pos, Color(0.6, 0.4, 0.2, 1))
	platforms.append(start_platform)
	
	# Generate platforms using smart placement rules
	var platform_count = _get_platform_count(config)
	var difficulty = _get_difficulty_for_level(level_number)
	
	for i in range(platform_count):
		var next_pos = _generate_smart_position(current_pos, platforms, difficulty, config)
		var platform_color = _get_platform_color(i, difficulty)
		var platform_size = _get_platform_size(difficulty, config)
		
		var platform = _create_platform(next_pos, platform_color, platform_size)
		platforms.append(platform)
		current_pos = next_pos
	
	# Place goal with reachability validation
	level.goal_position = _generate_reachable_goal_position(current_pos, platforms)
	level.platforms = platforms
	
	return level

func get_strategy_name() -> String:
	return "SmartPlacement"

func get_difficulty_multiplier() -> float:
	return 1.0  # Balanced difficulty

func _get_platform_count(config: GameConfig) -> int:
	var min_platforms = config.min_platforms_per_level if config else 4
	var max_platforms = config.max_platforms_per_level if config else 7
	return randi_range(min_platforms, max_platforms)

func _get_difficulty_for_level(level_number: int) -> float:
	var max_difficulty = 10
	return clamp((level_number - 2) / float(max_difficulty), 0.1, 1.0)

func _generate_smart_position(from_pos: Vector2, existing_platforms: Array, difficulty: float, config: GameConfig) -> Vector2:
	# Use the smart placement logic from LevelLoader
	var max_horizontal = config.max_horizontal_jump if config else 130.0
	var max_vertical_up = config.max_vertical_jump_up if config else 90.0
	var max_vertical_down = config.max_vertical_jump_down if config else 200.0
	
	# Increase challenge with difficulty
	var min_gap = 80 + int(difficulty * 40)
	var height_variation = 60 + int(difficulty * 80)
	
	var attempts = 0
	while attempts < 20:
		var horizontal_dir = 1 if randf() > 0.2 else -1  # Mostly go right
		var horizontal_distance = randi_range(min_gap, int(max_horizontal))
		var vertical_distance = randi_range(-int(max_vertical_up), int(max_vertical_down))
		
		# Add difficulty-based randomness
		if difficulty > 0.5:
			vertical_distance = randi_range(-height_variation, height_variation / 2)
		
		var next_pos = Vector2(
			from_pos.x + horizontal_distance * horizontal_dir,
			from_pos.y + vertical_distance
		)
		
		next_pos = _clamp_to_screen(next_pos)
		
		# Validate position using smart placement rules
		if _is_position_valid(next_pos, existing_platforms, Vector2(128, 32), config):
			if _is_position_reachable(from_pos, next_pos, config):
				return next_pos
		
		attempts += 1
	
	# Fallback: safe position to the right
	return Vector2(
		clamp(from_pos.x + 120, 150, 650),
		clamp(from_pos.y + randi_range(-50, 50), 150, 500)
	)

func _is_position_valid(pos: Vector2, existing_platforms: Array, new_platform_size: Vector2, config: GameConfig) -> bool:
	var min_spacing = config.min_platform_spacing if config else 80.0
	var min_jump_gap = config.min_jump_gap if config else 140.0
	
	for platform in existing_platforms:
		var platform_size = platform.size if platform is PlatformData else Vector2(128, 32)
		
		# Calculate distance between platform edges
		var new_rect = Rect2(pos - new_platform_size/2, new_platform_size)
		var existing_rect = Rect2(platform.position - platform_size/2, platform_size)
		
		var horizontal_distance = _get_rect_horizontal_distance(new_rect, existing_rect)
		var vertical_distance = _get_rect_vertical_distance(new_rect, existing_rect)
		
		# Enforce minimum spacing
		if horizontal_distance < min_spacing or vertical_distance < min_spacing:
			return false
		
		# For platforms at similar heights, enforce larger jump gap
		if vertical_distance < 60:
			if horizontal_distance < min_jump_gap:
				return false
	
	return true

func _get_rect_horizontal_distance(rect1: Rect2, rect2: Rect2) -> float:
	if rect1.intersects(rect2):
		return 0
	
	var left_gap = rect1.position.x - (rect2.position.x + rect2.size.x)
	var right_gap = rect2.position.x - (rect1.position.x + rect1.size.x)
	
	return max(left_gap, right_gap)

func _get_rect_vertical_distance(rect1: Rect2, rect2: Rect2) -> float:
	if rect1.intersects(rect2):
		return 0
	
	var top_gap = rect1.position.y - (rect2.position.y + rect2.size.y)
	var bottom_gap = rect2.position.y - (rect1.position.y + rect1.size.y)
	
	return max(top_gap, bottom_gap)

func _generate_reachable_goal_position(from_pos: Vector2, existing_platforms: Array) -> Vector2:
	var goal_pos = Vector2(
		from_pos.x + randi_range(80, 120),
		from_pos.y + randi_range(-80, -20)
	)
	return _clamp_to_screen(goal_pos)

func _get_platform_color(platform_index: int, difficulty: float) -> Color:
	# Dynamic color based on index and difficulty
	var hue = fmod(platform_index * 0.15, 1.0)
	var saturation = 0.6 + (difficulty * 0.3)
	var value = 0.8
	
	# Convert HSV to RGB (simplified)
	var c = value * saturation
	var x = c * (1 - abs(fmod(hue * 6, 2) - 1))
	var m = value - c
	
	var rgb = Vector3.ZERO
	if hue < 1.0/6:
		rgb = Vector3(c, x, 0)
	elif hue < 2.0/6:
		rgb = Vector3(x, c, 0)
	elif hue < 3.0/6:
		rgb = Vector3(0, c, x)
	elif hue < 4.0/6:
		rgb = Vector3(0, x, c)
	elif hue < 5.0/6:
		rgb = Vector3(x, 0, c)
	else:
		rgb = Vector3(c, 0, x)
	
	return Color(rgb.x + m, rgb.y + m, rgb.z + m, 1.0)

func _get_platform_size(difficulty: float, config: GameConfig) -> Vector2:
	var base_size = config.platform_size if config else Vector2(128, 32)
	var min_width = config.platform_size_variance.x if config else 100
	var max_width = config.platform_size_variance.y if config else 150
	
	# Size varies with difficulty
	var width_range = max_width - min_width
	var difficulty_adjusted_width = max_width - (difficulty * width_range * 0.5)
	var actual_width = randi_range(int(min_width), int(difficulty_adjusted_width))
	
	return Vector2(actual_width, base_size.y)