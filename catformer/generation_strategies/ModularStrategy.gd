extends LevelGenerationStrategy
class_name ModularStrategy

# ModularStrategy - Uses the modular level element system
# Creates levels by assembling pre-designed components

func generate_level(level_number: int, config: GameConfig) -> LevelData:
	var assembler = ModularLevelAssembler.new()
	
	# Determine assembly parameters based on level number
	var difficulty = _calculate_difficulty(level_number)
	var strategy = _select_assembly_strategy(level_number, difficulty)
	
	# Generate level using modular system
	var level_data = assembler.assemble_level(level_number, difficulty, strategy)
	
	# Apply any post-processing adjustments
	_apply_config_adjustments(level_data, config)
	
	return level_data

func get_strategy_name() -> String:
	return "Modular"

func get_difficulty_multiplier() -> float:
	return 1.1  # Slightly higher difficulty due to designed challenges

func _calculate_difficulty(level_number: int) -> float:
	# Progressive difficulty with some randomization
	var base_difficulty = clamp(level_number * 0.1, 0.2, 0.9)
	var randomization = randf_range(-0.1, 0.1)  # ±10% variation
	return clamp(base_difficulty + randomization, 0.1, 1.0)

func _select_assembly_strategy(level_number: int, difficulty: float) -> ModularLevelAssembler.AssemblyStrategy:
	# Early levels use simple linear arrangement
	if level_number < 5:
		return ModularLevelAssembler.AssemblyStrategy.LINEAR_CHAIN
	
	# Mid-level introduces vertical elements
	elif level_number < 10:
		if difficulty > 0.6:
			return ModularLevelAssembler.AssemblyStrategy.VERTICAL_TOWER
		else:
			return ModularLevelAssembler.AssemblyStrategy.LINEAR_CHAIN
	
	# Later levels can use more complex arrangements
	else:
		var strategies = [
			ModularLevelAssembler.AssemblyStrategy.LINEAR_CHAIN,
			ModularLevelAssembler.AssemblyStrategy.VERTICAL_TOWER,
			ModularLevelAssembler.AssemblyStrategy.SCATTERED_ISLANDS
		]
		return strategies[randi() % strategies.size()]

func _apply_config_adjustments(level_data: LevelData, config: GameConfig):
	if not config:
		return
	
	# Adjust platform colors based on config
	var platform_color = config.color_platform
	var ground_color = config.color_ground
	
	for platform in level_data.platforms:
		# Keep special colors (goals, challenges) but adjust basic platforms
		if platform.color == Color(0.4, 0.8, 0.4, 1):  # Standard green
			platform.color = platform_color
		elif platform.color == Color(0.6, 0.4, 0.2, 1):  # Ground brown
			platform.color = ground_color
	
	# Ensure spawn and goal positions are within reasonable bounds
	var min_y = config.platform_size.y if config.platform_size.y > 0 else 32
	var max_y = config.fall_death_y - 100 if config.fall_death_y > 0 else 700
	
	level_data.player_spawn_position.y = clamp(level_data.player_spawn_position.y, min_y, max_y)
	level_data.goal_position.y = clamp(level_data.goal_position.y, min_y, max_y)

# Enhanced validation for modular levels
func validate_level(level_data: LevelData, config: GameConfig) -> bool:
	if not super.validate_level(level_data, config):
		return false
	
	# Additional modular-specific validation
	
	# Check for reasonable platform distribution
	if level_data.platforms.size() < 3:
		return false
	
	# Ensure there's a clear path from spawn to goal
	var spawn_pos = level_data.player_spawn_position
	var goal_pos = level_data.goal_position
	
	# Basic reachability check - ensure goal isn't impossibly far
	var horizontal_distance = abs(goal_pos.x - spawn_pos.x)
	var max_reasonable_distance = 600  # Reasonable level width
	
	if horizontal_distance > max_reasonable_distance:
		return false
	
	# Check that platforms are reasonably spaced
	var platform_positions = []
	for platform in level_data.platforms:
		platform_positions.append(platform.position)
	
	# Ensure no two platforms are too close (overlap check)
	for i in range(platform_positions.size()):
		for j in range(i + 1, platform_positions.size()):
			var distance = platform_positions[i].distance_to(platform_positions[j])
			if distance < 50:  # Too close
				return false
	
	return true