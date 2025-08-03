extends LevelElement
class_name StartingAreaElement

# StartingAreaElement - Safe starting area with spawn platform
# Provides a reliable, comfortable beginning for any level

func _init(spawn_position: Vector2 = Vector2(100, 500)):
	super._init(ElementType.STARTING_AREA, "StartingArea")
	description = "Safe starting platform for player spawn"
	_build_starting_area(spawn_position)

func _build_starting_area(spawn_pos: Vector2):
	# Main spawn platform - wide and safe
	var spawn_platform = add_platform(
		spawn_pos,
		Color(0.6, 0.4, 0.2, 1),  # Brown ground color
		Vector2(160, 32)  # Wider than normal for safety
	)
	
	# Optional secondary platform for visual appeal
	if randf() > 0.3:  # 70% chance
		var support_platform = add_platform(
			spawn_pos + Vector2(-80, 50),
			Color(0.5, 0.3, 0.15, 1),  # Darker brown
			Vector2(100, 24)
		)
	
	# Add connection points for linking to other elements
	add_connection_point(spawn_pos + Vector2(80, 0))   # Right edge
	add_connection_point(spawn_pos + Vector2(-80, 0))  # Left edge
	add_connection_point(spawn_pos + Vector2(0, -40))  # Top center
	
	# Update properties
	difficulty_rating = 0.0  # Completely safe
	tags = ["safe", "start", "wide"]
	required_skills = []

# Get the spawn position for the player
func get_spawn_position() -> Vector2:
	if platforms.is_empty():
		return Vector2.ZERO
	return platforms[0].position + Vector2(0, -20)  # Slightly above platform

# Ensure starting area is always accessible
func validate() -> bool:
	if not super.validate():
		return false
	
	# Starting area should have at least one platform
	if platforms.is_empty():
		return false
	
	# Main platform should be reasonably sized
	var main_platform = platforms[0]
	if main_platform.size.x < 128:  # Minimum width
		return false
	
	return true