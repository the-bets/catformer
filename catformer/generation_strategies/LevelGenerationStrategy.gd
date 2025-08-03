extends RefCounted
class_name LevelGenerationStrategy

# LevelGenerationStrategy - Base class for all level generation strategies
# Implements the Strategy Pattern for flexible, interchangeable generation algorithms

# Abstract method - must be implemented by concrete strategies
func generate_level(level_number: int, config: GameConfig) -> LevelData:
	push_error("LevelGenerationStrategy.generate_level() must be implemented by subclass")
	return null

# Helper method for validation - can be overridden by strategies
func validate_level(level_data: LevelData, config: GameConfig) -> bool:
	if not level_data:
		return false
	
	if level_data.platforms.is_empty():
		return false
	
	# Basic validation - ensure spawn and goal are set
	if level_data.player_spawn_position == Vector2.ZERO:
		return false
	
	if level_data.goal_position == Vector2.ZERO:
		return false
	
	return true

# Get strategy name for debugging/logging
func get_strategy_name() -> String:
	return "BaseStrategy"

# Get difficulty estimate for this strategy
func get_difficulty_multiplier() -> float:
	return 1.0

# Helper to create a basic platform
func _create_platform(position: Vector2, color: Color = Color.WHITE, size: Vector2 = Vector2(128, 32)) -> PlatformData:
	var platform = PlatformData.new()
	platform.position = position
	platform.color = color
	platform.size = size
	return platform

# Helper to keep positions within screen bounds
func _clamp_to_screen(position: Vector2) -> Vector2:
	return Vector2(
		clamp(position.x, 100, 700),
		clamp(position.y, 100, 550)
	)

# Helper to calculate distance between two points
func _get_distance(pos1: Vector2, pos2: Vector2) -> float:
	return pos1.distance_to(pos2)

# Helper to check if a position is reachable from another
func _is_position_reachable(from_pos: Vector2, to_pos: Vector2, config: GameConfig) -> bool:
	var horizontal_distance = abs(to_pos.x - from_pos.x)
	var vertical_distance = to_pos.y - from_pos.y  # Positive = down, negative = up
	
	var max_horizontal = config.max_horizontal_jump if config else 130.0
	var max_vertical_up = config.max_vertical_jump_up if config else 90.0
	var max_vertical_down = config.max_vertical_jump_down if config else 200.0
	
	# Check horizontal reachability
	if horizontal_distance > max_horizontal:
		return false
	
	# Check vertical reachability
	if vertical_distance < 0:  # Going up
		if abs(vertical_distance) > max_vertical_up:
			return false
	else:  # Going down
		if vertical_distance > max_vertical_down:
			return false
	
	return true