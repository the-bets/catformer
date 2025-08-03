extends LevelElement
class_name PlatformGroupElement

# PlatformGroupElement - Basic collection of platforms
# Simple, reliable building blocks for level construction

enum GroupType {
	LINEAR,        # Platforms in a line
	CLUSTERED,     # Platforms grouped together
	SCATTERED,     # Randomly distributed platforms
	STAIRCASE,     # Step-like progression
	BRIDGE         # Spanning a gap
}

var group_type: GroupType
var platform_count: int

func _init(type: GroupType = GroupType.LINEAR, center_pos: Vector2 = Vector2(400, 400), count: int = 3):
	super._init(ElementType.PLATFORM_GROUP, "PlatformGroup_" + _get_group_name(type))
	group_type = type
	platform_count = clamp(count, 2, 6)
	description = "A " + _get_group_name(type) + " arrangement of " + str(platform_count) + " platforms"
	_build_group(center_pos)

func _build_group(center_pos: Vector2):
	match group_type:
		GroupType.LINEAR:
			_build_linear_group(center_pos)
		GroupType.CLUSTERED:
			_build_clustered_group(center_pos)
		GroupType.SCATTERED:
			_build_scattered_group(center_pos)
		GroupType.STAIRCASE:
			_build_staircase_group(center_pos)
		GroupType.BRIDGE:
			_build_bridge_group(center_pos)
	
	_update_group_properties()

func _build_linear_group(center_pos: Vector2):
	difficulty_rating = 0.2
	tags = ["basic", "linear", "simple"]
	required_skills = ["basic_movement"]
	
	var start_pos = center_pos + Vector2(-platform_count * 60, 0)
	
	for i in range(platform_count):
		var platform_pos = start_pos + Vector2(i * 120, 0)
		var platform_color = Color(0.4, 0.8, 0.4, 1)  # Standard green
		var platform_size = Vector2(128, 32)
		
		add_platform(platform_pos, platform_color, platform_size)
	
	# Connection points at both ends
	add_connection_point(start_pos + Vector2(-64, 0))
	add_connection_point(start_pos + Vector2((platform_count - 1) * 120 + 64, 0))

func _build_clustered_group(center_pos: Vector2):
	difficulty_rating = 0.3
	tags = ["clustered", "grouped", "basic"]
	required_skills = ["basic_jump"]
	
	# Create platforms in a rough cluster around center
	for i in range(platform_count):
		var angle = (i / float(platform_count)) * TAU
		var radius = randi_range(60, 100)
		var offset = Vector2(cos(angle), sin(angle)) * radius
		
		var platform_pos = center_pos + offset
		var platform_color = Color(0.5, 0.7, 0.5, 1)
		var platform_size = Vector2(randi_range(100, 140), 32)
		
		add_platform(platform_pos, platform_color, platform_size)
	
	# Multiple connection points around the cluster
	for i in range(4):
		var angle = i * PI / 2
		var connection_pos = center_pos + Vector2(cos(angle), sin(angle)) * 120
		add_connection_point(connection_pos)

func _build_scattered_group(center_pos: Vector2):
	difficulty_rating = 0.4
	tags = ["scattered", "random", "varied"]
	required_skills = ["basic_jump", "navigation"]
	
	var area_size = Vector2(250, 150)
	
	for i in range(platform_count):
		var random_offset = Vector2(
			randf_range(-area_size.x/2, area_size.x/2),
			randf_range(-area_size.y/2, area_size.y/2)
		)
		
		var platform_pos = center_pos + random_offset
		var platform_color = Color(
			randf_range(0.4, 0.8),
			randf_range(0.6, 0.9),
			randf_range(0.3, 0.7),
			1.0
		)
		var platform_size = Vector2(randi_range(90, 130), 32)
		
		add_platform(platform_pos, platform_color, platform_size)
	
	# Connection points on the edges
	add_connection_point(center_pos + Vector2(-area_size.x/2 - 50, 0))
	add_connection_point(center_pos + Vector2(area_size.x/2 + 50, 0))

func _build_staircase_group(center_pos: Vector2):
	difficulty_rating = 0.3
	tags = ["staircase", "ascending", "structured"]
	required_skills = ["basic_jump"]
	
	var direction = 1 if randf() > 0.5 else -1  # Up or down
	var step_size = Vector2(80, -40 * direction)
	var start_pos = center_pos + Vector2(-platform_count * 40, direction * 20)
	
	for i in range(platform_count):
		var platform_pos = start_pos + step_size * i
		var platform_color = Color(0.6, 0.5, 0.7, 1)  # Purple-ish
		var platform_size = Vector2(110, 32)
		
		add_platform(platform_pos, platform_color, platform_size)
	
	# Connection at bottom and top
	if direction > 0:  # Going up
		add_connection_point(start_pos + Vector2(-55, 0))
		add_connection_point(start_pos + step_size * (platform_count - 1) + Vector2(55, 0))
	else:  # Going down
		add_connection_point(start_pos + Vector2(-55, 0))
		add_connection_point(start_pos + step_size * (platform_count - 1) + Vector2(55, 0))

func _build_bridge_group(center_pos: Vector2):
	difficulty_rating = 0.4
	tags = ["bridge", "gap", "spanning"]
	required_skills = ["basic_jump", "distance_jumping"]
	
	var bridge_width = platform_count * 100
	var start_pos = center_pos + Vector2(-bridge_width/2, 0)
	
	for i in range(platform_count):
		var platform_pos = start_pos + Vector2(i * (bridge_width / (platform_count - 1)), 0)
		var platform_color = Color(0.7, 0.6, 0.4, 1)  # Wooden bridge color
		var platform_size = Vector2(90, 28)  # Slightly smaller for challenge
		
		add_platform(platform_pos, platform_color, platform_size)
	
	# Connection points at bridge ends
	add_connection_point(start_pos + Vector2(-70, 0))
	add_connection_point(start_pos + Vector2(bridge_width + 70, 0))

func _update_group_properties():
	# Adjust difficulty based on platform count and spacing
	var spacing_penalty = 0.0
	if platforms.size() > 1:
		var total_distance = 0.0
		for i in range(platforms.size() - 1):
			total_distance += platforms[i].position.distance_to(platforms[i + 1].position)
		var average_distance = total_distance / (platforms.size() - 1)
		if average_distance > 120:  # Large gaps increase difficulty
			spacing_penalty = (average_distance - 120) / 400.0  # Up to +0.2 difficulty
	
	difficulty_rating = clamp(difficulty_rating + spacing_penalty, 0.1, 0.8)
	_update_bounds()

func _get_group_name(type: GroupType) -> String:
	match type:
		GroupType.LINEAR: return "Linear"
		GroupType.CLUSTERED: return "Clustered"
		GroupType.SCATTERED: return "Scattered"
		GroupType.STAIRCASE: return "Staircase"
		GroupType.BRIDGE: return "Bridge"
		_: return "Unknown"