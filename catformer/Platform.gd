extends StaticBody2D
class_name Platform

@export var platform_color: Color = Color(0.4, 0.8, 0.4, 1)
@export var platform_size: Vector2 = Vector2(128, 32)

# Object pooling support
var platform_type: String = "standard"
var is_pooled: bool = false
var original_parent: Node

func _ready():
	# Use config defaults if not explicitly overridden
	if GameConfig.current:
		if platform_color == Color(0.4, 0.8, 0.4, 1):
			platform_color = GameConfig.current.color_platform
		if platform_size == Vector2(128, 32):
			platform_size = GameConfig.current.platform_size
	setup_platform()

func setup_platform():
	var collision_shape = $CollisionShape2D
	var color_rect = $ColorRect
	
	collision_shape.shape.size = platform_size
	color_rect.color = platform_color
	
	var visual_size = platform_size / 2
	color_rect.offset_left = -visual_size.x
	color_rect.offset_top = -visual_size.y
	color_rect.offset_right = visual_size.x
	color_rect.offset_bottom = visual_size.y

# Configure platform with PlatformData
func configure_platform(platform_data: PlatformData):
	if platform_data:
		platform_color = platform_data.color
		platform_size = platform_data.size
		global_position = platform_data.position
		setup_platform()

# Object pooling lifecycle methods
func _on_pooled_object_created():
	is_pooled = true
	print("Platform: Created for pooling")

func _on_pooled_object_retrieved():
	# Reset platform state when retrieved from pool
	show()
	set_collision_layer_value(1, true)  # Re-enable collision
	set_collision_mask_value(1, true)
	
	# Ensure platform is properly configured
	setup_platform()
	
	print("Platform: Retrieved from pool")

func _on_pooled_object_returned():
	# Clean up platform when returned to pool
	hide()
	set_collision_layer_value(1, false)  # Disable collision
	set_collision_mask_value(1, false)
	
	# Store parent reference but don't remove (pool handles that)
	if get_parent():
		original_parent = get_parent()
	
	print("Platform: Returned to pool")

func _on_pooled_object_destroyed():
	print("Platform: Destroyed from pool")

# Reset platform to default state
func reset():
	platform_color = Color(0.4, 0.8, 0.4, 1)
	platform_size = Vector2(128, 32)
	global_position = Vector2.ZERO
	show()
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)

# Get platform type for pool management
func get_platform_type() -> String:
	return platform_type

# Set platform type for pool management
func set_platform_type(type: String):
	platform_type = type