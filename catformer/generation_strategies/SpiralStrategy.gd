extends LevelGenerationStrategy
class_name SpiralStrategy

# SpiralStrategy - Creates levels that spiral upward in circular or square patterns
# Emphasizes vertical movement and spatial awareness

func generate_level(level_number: int, config: GameConfig) -> LevelData:
	var level = LevelData.new()
	level.level_number = level_number
	level.player_spawn_position = Vector2(400, 500)  # Center bottom
	
	var platforms = []
	var center = Vector2(400, 350)  # Center of spiral
	var current_radius = 150
	var current_angle = PI  # Start at the bottom
	
	# Create starting platform
	var start_pos = Vector2(400, 500)
	var start_platform = _create_platform(start_pos, Color(0.6, 0.4, 0.2, 1))
	platforms.append(start_platform)
	
	# Generate spiral pattern
	var platform_count = _get_platform_count(config)
	var difficulty = _get_difficulty_for_level(level_number)
	var angle_step = _get_angle_step(difficulty)
	var radius_change = _get_radius_change(difficulty)
	
	for i in range(platform_count):
		var next_pos = _generate_spiral_position(center, current_radius, current_angle)
		var platform_color = _get_platform_color_for_height(next_pos.y)
		var platform_size = _get_platform_size(difficulty, config)
		
		var platform = _create_platform(next_pos, platform_color, platform_size)
		platforms.append(platform)
		
		# Update spiral parameters
		current_angle += angle_step
		current_radius += radius_change
		current_radius = clamp(current_radius, 80, 200)  # Keep reasonable bounds
	
	# Place goal at the center/top of the spiral
	level.goal_position = Vector2(center.x, center.y - 100)
	level.platforms = platforms
	
	return level

func get_strategy_name() -> String:
	return "Spiral"

func get_difficulty_multiplier() -> float:
	return 1.3  # More challenging due to 3D-like navigation

func _get_platform_count(config: GameConfig) -> int:
	var min_platforms = config.min_platforms_per_level if config else 6
	var max_platforms = config.max_platforms_per_level if config else 9
	return randi_range(min_platforms, max_platforms)

func _get_difficulty_for_level(level_number: int) -> float:
	return clamp(level_number * 0.15, 0.3, 1.0)

func _get_angle_step(difficulty: float) -> float:
	# Larger angle steps = wider spiral, easier to navigate
	var base_step = PI / 2.5  # About 72 degrees
	var difficulty_modifier = difficulty * 0.3
	return base_step + difficulty_modifier

func _get_radius_change(difficulty: float) -> float:
	# How much the radius changes each step (negative = inward spiral)
	return -5.0 - (difficulty * 10)  # -5 to -15 pixels per platform

func _generate_spiral_position(center: Vector2, radius: float, angle: float) -> Vector2:
	var spiral_pos = Vector2(
		center.x + cos(angle) * radius,
		center.y + sin(angle) * radius
	)
	return _clamp_to_screen(spiral_pos)

func _get_platform_color_for_height(y_position: float) -> Color:
	# Color gradient based on height (higher = cooler colors)
	var height_ratio = (550 - y_position) / 450.0  # 0 = bottom, 1 = top
	height_ratio = clamp(height_ratio, 0.0, 1.0)
	
	# Interpolate from warm (bottom) to cool (top)
	var red = 0.8 - (height_ratio * 0.4)    # 0.8 to 0.4
	var green = 0.4 + (height_ratio * 0.4)  # 0.4 to 0.8
	var blue = 0.4 + (height_ratio * 0.4)   # 0.4 to 0.8
	
	return Color(red, green, blue, 1.0)

func _get_platform_size(difficulty: float, config: GameConfig) -> Vector2:
	var base_size = config.platform_size if config else Vector2(128, 32)
	# Smaller platforms for spiral navigation
	var size_multiplier = 0.9 - (difficulty * 0.2)  # 90% to 70% size
	return Vector2(base_size.x * size_multiplier, base_size.y)