extends LevelElement
class_name EndingAreaElement

# EndingAreaElement - Goal area with final platform and decoration
# Provides a satisfying conclusion to level segments

var goal_position: Vector2

func _init(goal_pos: Vector2 = Vector2(700, 300)):
	super._init(ElementType.ENDING_AREA, "EndingArea")
	description = "Goal area with final platform and objective"
	goal_position = goal_pos
	_build_ending_area()

func _build_ending_area():
	# Main goal platform - elevated and distinctive
	var goal_platform = add_platform(
		goal_position,
		Color(0.8, 0.7, 0.3, 1),  # Golden color for goal
		Vector2(140, 32)
	)
	
	# Optional approach platform for easier access
	if randf() > 0.4:  # 60% chance
		var approach_platform = add_platform(
			goal_position + Vector2(-120, 40),
			Color(0.7, 0.6, 0.2, 1),  # Slightly darker gold
			Vector2(100, 28)
		)
	
	# Decorative platforms around the goal
	if randf() > 0.5:  # 50% chance for decoration
		# Small decorative platforms
		for i in range(randi_range(1, 3)):
			var decoration_offset = Vector2(
				randf_range(-80, 80),
				randf_range(-60, -20)
			)
			add_platform(
				goal_position + decoration_offset,
				Color(0.6, 0.5, 0.2, 0.8),  # Semi-transparent decoration
				Vector2(randi_range(40, 70), 20)
			)
	
	# Add connection points for approach
	add_connection_point(goal_position + Vector2(-100, 0))  # Left approach
	add_connection_point(goal_position + Vector2(0, 60))    # Bottom approach
	if platforms.size() > 1:  # If there's an approach platform
		add_connection_point(goal_position + Vector2(-180, 40))  # Extended left approach
	
	# Update properties
	difficulty_rating = 0.1  # Goal should be easy to reach once you're close
	tags = ["goal", "ending", "safe", "golden"]
	required_skills = []

# Get the exact goal position where the goal object should be placed
func get_goal_position() -> Vector2:
	return goal_position + Vector2(0, -30)  # Slightly above the platform

# Get the final platform for spawn positioning
func get_final_platform_position() -> Vector2:
	if platforms.is_empty():
		return goal_position
	
	# Find the platform closest to the goal position
	var closest_platform = platforms[0]
	var closest_distance = goal_position.distance_to(closest_platform.position)
	
	for platform in platforms:
		var distance = goal_position.distance_to(platform.position)
		if distance < closest_distance:
			closest_distance = distance
			closest_platform = platform
	
	return closest_platform.position

# Ensure ending area is appropriately positioned and accessible
func validate() -> bool:
	if not super.validate():
		return false
	
	# Should have at least one platform (the goal platform)
	if platforms.is_empty():
		return false
	
	# Goal platform should be reasonably sized
	var goal_platform = platforms[0]  # First platform is the main goal platform
	if goal_platform.size.x < 100:
		return false
	
	# Should have at least one connection point for approach
	if connection_points.is_empty():
		return false
	
	return true

# Get visual information for the goal area
func get_goal_info() -> Dictionary:
	return {
		"goal_position": get_goal_position(),
		"platform_position": get_final_platform_position(),
		"platform_count": platforms.size(),
		"has_decoration": platforms.size() > 2,
		"connection_points": connection_points.size()
	}