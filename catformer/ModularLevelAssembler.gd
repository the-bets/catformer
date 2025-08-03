extends RefCounted
class_name ModularLevelAssembler

# ModularLevelAssembler - Combines level elements into complete levels
# Provides intelligent assembly of modular components with connection validation

# Assembly strategies
enum AssemblyStrategy {
	LINEAR_CHAIN,      # Elements connected in a straight line
	BRANCHING_PATHS,   # Multiple paths with choices
	VERTICAL_TOWER,    # Stacked elements going upward
	SCATTERED_ISLANDS, # Separate element clusters
	GUIDED_TOUR        # Curated path through various elements
}

# Assembly configuration
var target_difficulty: float = 0.5
var max_elements: int = 6
var min_elements: int = 3
var assembly_strategy: AssemblyStrategy = AssemblyStrategy.LINEAR_CHAIN
var level_bounds: Rect2 = Rect2(50, 50, 750, 500)

# Element library
var available_elements: Array[LevelElement] = []
var required_elements: Array[LevelElement] = []  # Must include these

func _init():
	_initialize_element_library()

# Main assembly method
func assemble_level(level_number: int, difficulty: float = 0.5, strategy: AssemblyStrategy = AssemblyStrategy.LINEAR_CHAIN) -> LevelData:
	target_difficulty = difficulty
	assembly_strategy = strategy
	
	# Create level data structure
	var level_data = LevelData.new()
	level_data.level_number = level_number
	
	# Select and arrange elements
	var selected_elements = _select_elements_for_difficulty(difficulty)
	var arranged_elements = _arrange_elements(selected_elements, strategy)
	
	# Extract platforms and positions from arranged elements
	var all_platforms = []
	var spawn_position = Vector2(100, 450)
	var goal_position = Vector2(700, 300)
	
	for element_info in arranged_elements:
		var element = element_info.element
		var offset = element_info.offset
		
		# Get transformed platforms
		var element_platforms = element.get_transformed_platforms(offset)
		all_platforms.append_array(element_platforms)
		
		# Update spawn and goal positions
		if element is StartingAreaElement:
			spawn_position = element.get_spawn_position() + offset
		elif element is EndingAreaElement:
			goal_position = element.get_goal_position() + offset
	
	# Finalize level data
	level_data.platforms = all_platforms
	level_data.player_spawn_position = spawn_position
	level_data.goal_position = goal_position
	
	# Validate and fix if necessary
	if not _validate_assembled_level(level_data):
		level_data = _fix_level_issues(level_data)
	
	return level_data

# Select elements based on target difficulty
func _select_elements_for_difficulty(difficulty: float) -> Array[LevelElement]:
	var selected = []
	var remaining_difficulty = difficulty
	var element_count = randi_range(min_elements, max_elements)
	
	# Always start with a starting area
	var start_element = StartingAreaElement.new(Vector2.ZERO)
	selected.append(start_element)
	remaining_difficulty -= start_element.difficulty_rating
	
	# Always end with an ending area
	var end_element = EndingAreaElement.new(Vector2.ZERO)
	selected.append(end_element)
	remaining_difficulty -= end_element.difficulty_rating
	
	# Fill middle with appropriate elements
	var middle_count = element_count - 2
	for i in range(middle_count):
		var target_element_difficulty = remaining_difficulty / (middle_count - i)
		var element = _select_best_element_for_difficulty(target_element_difficulty)
		
		if element:
			selected.append(element)
			remaining_difficulty -= element.difficulty_rating
		else:
			# Fallback to a basic platform group
			var fallback = PlatformGroupElement.new(PlatformGroupElement.GroupType.LINEAR, Vector2.ZERO, 3)
			selected.append(fallback)
			remaining_difficulty -= fallback.difficulty_rating
	
	return selected

# Find the best element for a target difficulty
func _select_best_element_for_difficulty(target_difficulty: float) -> LevelElement:
	var best_element = null
	var best_difference = 999.0
	
	# Try different element types
	var element_options = [
		_create_platform_group_for_difficulty(target_difficulty),
		_create_jump_challenge_for_difficulty(target_difficulty)
	]
	
	for element in element_options:
		var difference = abs(element.difficulty_rating - target_difficulty)
		if difference < best_difference:
			best_difference = difference
			best_element = element
	
	return best_element

# Create platform group matching target difficulty
func _create_platform_group_for_difficulty(target_difficulty: float) -> PlatformGroupElement:
	var group_type: PlatformGroupElement.GroupType
	var platform_count: int
	
	if target_difficulty < 0.3:
		group_type = PlatformGroupElement.GroupType.LINEAR
		platform_count = 3
	elif target_difficulty < 0.5:
		group_type = PlatformGroupElement.GroupType.STAIRCASE
		platform_count = 4
	elif target_difficulty < 0.7:
		group_type = PlatformGroupElement.GroupType.SCATTERED
		platform_count = 4
	else:
		group_type = PlatformGroupElement.GroupType.BRIDGE
		platform_count = 5
	
	return PlatformGroupElement.new(group_type, Vector2.ZERO, platform_count)

# Create jump challenge matching target difficulty
func _create_jump_challenge_for_difficulty(target_difficulty: float) -> JumpChallengeElement:
	var challenge_type: JumpChallengeElement.ChallengeType
	var platform_count: int
	
	if target_difficulty < 0.4:
		challenge_type = JumpChallengeElement.ChallengeType.LONG_JUMPS
		platform_count = 3
	elif target_difficulty < 0.6:
		challenge_type = JumpChallengeElement.ChallengeType.PRECISION_JUMPS
		platform_count = 4
	elif target_difficulty < 0.8:
		challenge_type = JumpChallengeElement.ChallengeType.VERTICAL_CLIMB
		platform_count = 4
	else:
		challenge_type = JumpChallengeElement.ChallengeType.COMBO_JUMPS
		platform_count = 5
	
	return JumpChallengeElement.new(challenge_type, Vector2.ZERO, platform_count)

# Arrange elements according to strategy
func _arrange_elements(elements: Array[LevelElement], strategy: AssemblyStrategy) -> Array:
	match strategy:
		AssemblyStrategy.LINEAR_CHAIN:
			return _arrange_linear_chain(elements)
		AssemblyStrategy.BRANCHING_PATHS:
			return _arrange_branching_paths(elements)
		AssemblyStrategy.VERTICAL_TOWER:
			return _arrange_vertical_tower(elements)
		AssemblyStrategy.SCATTERED_ISLANDS:
			return _arrange_scattered_islands(elements)
		AssemblyStrategy.GUIDED_TOUR:
			return _arrange_guided_tour(elements)
		_:
			return _arrange_linear_chain(elements)

# Linear chain arrangement - elements connected left to right
func _arrange_linear_chain(elements: Array[LevelElement]) -> Array:
	var arranged = []
	var current_x = level_bounds.position.x + 50
	var base_y = level_bounds.position.y + level_bounds.size.y * 0.7  # Lower portion of level
	
	for i in range(elements.size()):
		var element = elements[i]
		var element_bounds = element.get_bounds()
		
		# Position element
		var offset = Vector2(current_x - element_bounds.position.x, base_y - element_bounds.position.y)
		
		# Add some vertical variation for middle elements
		if i > 0 and i < elements.size() - 1:
			offset.y += randf_range(-50, 50)
		
		# Ensure element stays within bounds
		offset.y = clamp(offset.y, level_bounds.position.y, level_bounds.position.y + level_bounds.size.y - element_bounds.size.y)
		
		arranged.append({
			"element": element,
			"offset": offset,
			"index": i
		})
		
		# Move to next position
		current_x += element_bounds.size.x + randi_range(80, 150)
	
	return arranged

func _arrange_vertical_tower(elements: Array[LevelElement]) -> Array:
	var arranged = []
	var center_x = level_bounds.position.x + level_bounds.size.x * 0.5
	var current_y = level_bounds.position.y + level_bounds.size.y - 100  # Start at bottom
	
	for i in range(elements.size()):
		var element = elements[i]
		var element_bounds = element.get_bounds()
		
		# Position element at center horizontally, stacked vertically
		var offset = Vector2(
			center_x - element_bounds.position.x - element_bounds.size.x * 0.5,
			current_y - element_bounds.position.y - element_bounds.size.y
		)
		
		arranged.append({
			"element": element,
			"offset": offset,
			"index": i
		})
		
		# Move up for next element
		current_y -= element_bounds.size.y + randi_range(60, 120)
	
	return arranged

func _arrange_scattered_islands(elements: Array[LevelElement]) -> Array:
	var arranged = []
	
	for i in range(elements.size()):
		var element = elements[i]
		var element_bounds = element.get_bounds()
		
		# Random position within bounds
		var offset = Vector2(
			randf_range(level_bounds.position.x, level_bounds.position.x + level_bounds.size.x - element_bounds.size.x),
			randf_range(level_bounds.position.y, level_bounds.position.y + level_bounds.size.y - element_bounds.size.y)
		)
		
		arranged.append({
			"element": element,
			"offset": offset,
			"index": i
		})
	
	return arranged

func _arrange_branching_paths(elements: Array[LevelElement]) -> Array:
	# Simplified: use linear arrangement for now
	return _arrange_linear_chain(elements)

func _arrange_guided_tour(elements: Array[LevelElement]) -> Array:
	# Simplified: use linear arrangement for now
	return _arrange_linear_chain(elements)

func _validate_assembled_level(level_data: LevelData) -> bool:
	# Basic validation
	if level_data.platforms.is_empty():
		return false
	
	if level_data.player_spawn_position == Vector2.ZERO:
		return false
	
	if level_data.goal_position == Vector2.ZERO:
		return false
	
	return true

func _fix_level_issues(level_data: LevelData) -> LevelData:
	# Ensure we have platforms
	if level_data.platforms.is_empty():
		var fallback_platform = PlatformData.new()
		fallback_platform.position = Vector2(400, 400)
		fallback_platform.color = Color(0.5, 0.5, 0.5, 1)
		fallback_platform.size = Vector2(128, 32)
		level_data.platforms.append(fallback_platform)
	
	# Ensure spawn position is set
	if level_data.player_spawn_position == Vector2.ZERO:
		level_data.player_spawn_position = Vector2(100, 450)
	
	# Ensure goal position is set
	if level_data.goal_position == Vector2.ZERO:
		level_data.goal_position = Vector2(700, 300)
	
	return level_data

func _initialize_element_library():
	# This could be expanded to load elements from files or generate variations
	pass