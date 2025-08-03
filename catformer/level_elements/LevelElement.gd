extends RefCounted
class_name LevelElement

# LevelElement - Base class for modular level components
# Provides a composable system for building complex levels from smaller pieces

enum ElementType {
	PLATFORM_GROUP,    # Collection of platforms
	JUMP_CHALLENGE,    # Specific jumping puzzle
	OBSTACLE_COURSE,   # Series of obstacles
	VERTICAL_CLIMB,    # Upward movement section
	HORIZONTAL_GAP,    # Wide gap crossing
	STARTING_AREA,     # Safe spawn area
	ENDING_AREA,       # Goal area
	DECORATION        # Visual elements only
}

# Element properties
var element_type: ElementType
var name: String
var description: String
var difficulty_rating: float = 0.5  # 0.0 = very easy, 1.0 = very hard
var size: Vector2  # Bounding box size
var connection_points: Array[Vector2] = []  # Where other elements can connect
var platforms: Array[PlatformData] = []
var required_skills: Array[String] = []  # e.g., ["basic_jump", "precision_jumping"]
var tags: Array[String] = []  # e.g., ["beginner", "vertical", "challenge"]

# Constructor
func _init(type: ElementType = ElementType.PLATFORM_GROUP, element_name: String = ""):
	element_type = type
	name = element_name if element_name != "" else _get_default_name()
	_setup_default_properties()

# Get element bounds as a Rect2
func get_bounds() -> Rect2:
	if platforms.is_empty():
		return Rect2(Vector2.ZERO, size)
	
	var min_pos = platforms[0].position
	var max_pos = platforms[0].position
	
	for platform in platforms:
		var platform_bounds = Rect2(
			platform.position - platform.size/2, 
			platform.size
		)
		min_pos = Vector2(
			min(min_pos.x, platform_bounds.position.x),
			min(min_pos.y, platform_bounds.position.y)
		)
		max_pos = Vector2(
			max(max_pos.x, platform_bounds.position.x + platform_bounds.size.x),
			max(max_pos.y, platform_bounds.position.y + platform_bounds.size.y)
		)
	
	return Rect2(min_pos, max_pos - min_pos)

# Add a platform to this element
func add_platform(position: Vector2, color: Color = Color.WHITE, size: Vector2 = Vector2(128, 32)) -> PlatformData:
	var platform = PlatformData.new()
	platform.position = position
	platform.color = color
	platform.size = size
	platforms.append(platform)
	_update_bounds()
	return platform

# Add a connection point where other elements can attach
func add_connection_point(point: Vector2):
	connection_points.append(point)

# Transform element (move, scale, rotate)
func transform_element(offset: Vector2, scale_factor: float = 1.0):
	# Move all platforms
	for platform in platforms:
		platform.position += offset
		if scale_factor != 1.0:
			platform.size *= scale_factor
	
	# Move connection points
	for i in range(connection_points.size()):
		connection_points[i] += offset
	
	# Update size
	if scale_factor != 1.0:
		size *= scale_factor
	
	_update_bounds()

# Check if this element can connect to another at a specific point
func can_connect_to(other: LevelElement, connection_point: Vector2, other_point: Vector2) -> bool:
	# Basic connection validation
	if connection_point not in connection_points:
		return false
	if other_point not in other.connection_points:
		return false
	
	# Check if connection would cause overlap (basic check)
	var offset = other_point - connection_point
	var other_bounds = other.get_bounds()
	other_bounds.position += offset
	
	return not get_bounds().intersects(other_bounds)

# Get all platforms with transforms applied
func get_transformed_platforms(offset: Vector2 = Vector2.ZERO, scale: float = 1.0) -> Array[PlatformData]:
	var transformed = []
	for platform in platforms:
		var new_platform = PlatformData.new()
		new_platform.position = platform.position + offset
		new_platform.color = platform.color
		new_platform.size = platform.size * scale
		transformed.append(new_platform)
	return transformed

# Validate element integrity
func validate() -> bool:
	if platforms.is_empty():
		return false
	
	# Check for reasonable bounds
	var bounds = get_bounds()
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		return false
	
	# Check for overlapping platforms
	for i in range(platforms.size()):
		for j in range(i + 1, platforms.size()):
			var rect1 = Rect2(platforms[i].position - platforms[i].size/2, platforms[i].size)
			var rect2 = Rect2(platforms[j].position - platforms[j].size/2, platforms[j].size)
			if rect1.intersects(rect2):
				return false
	
	return true

# Get element info for debugging
func get_info() -> Dictionary:
	return {
		"name": name,
		"type": _get_type_string(),
		"difficulty": difficulty_rating,
		"platform_count": platforms.size(),
		"connection_points": connection_points.size(),
		"size": size,
		"bounds": get_bounds(),
		"tags": tags,
		"skills": required_skills
	}

# Private methods
func _get_default_name() -> String:
	return _get_type_string() + "_" + str(randi() % 1000)

func _get_type_string() -> String:
	match element_type:
		ElementType.PLATFORM_GROUP: return "PlatformGroup"
		ElementType.JUMP_CHALLENGE: return "JumpChallenge"
		ElementType.OBSTACLE_COURSE: return "ObstacleCourse"
		ElementType.VERTICAL_CLIMB: return "VerticalClimb"
		ElementType.HORIZONTAL_GAP: return "HorizontalGap"
		ElementType.STARTING_AREA: return "StartingArea"
		ElementType.ENDING_AREA: return "EndingArea"
		ElementType.DECORATION: return "Decoration"
		_: return "Unknown"

func _setup_default_properties():
	match element_type:
		ElementType.PLATFORM_GROUP:
			difficulty_rating = 0.3
			size = Vector2(200, 150)
			tags = ["basic", "platforms"]
		ElementType.JUMP_CHALLENGE:
			difficulty_rating = 0.7
			size = Vector2(300, 200)
			tags = ["challenge", "jumping"]
			required_skills = ["precision_jumping"]
		ElementType.OBSTACLE_COURSE:
			difficulty_rating = 0.8
			size = Vector2(400, 250)
			tags = ["challenge", "complex"]
			required_skills = ["advanced_movement"]
		ElementType.VERTICAL_CLIMB:
			difficulty_rating = 0.6
			size = Vector2(150, 300)
			tags = ["vertical", "climbing"]
			required_skills = ["basic_jump"]
		ElementType.HORIZONTAL_GAP:
			difficulty_rating = 0.5
			size = Vector2(250, 100)
			tags = ["gap", "horizontal"]
			required_skills = ["basic_jump"]
		ElementType.STARTING_AREA:
			difficulty_rating = 0.1
			size = Vector2(150, 100)
			tags = ["safe", "start"]
		ElementType.ENDING_AREA:
			difficulty_rating = 0.2
			size = Vector2(150, 100)
			tags = ["safe", "goal"]
		ElementType.DECORATION:
			difficulty_rating = 0.0
			size = Vector2(100, 100)
			tags = ["visual", "decoration"]

func _update_bounds():
	var bounds = get_bounds()
	size = bounds.size