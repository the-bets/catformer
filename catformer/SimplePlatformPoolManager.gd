class_name SimplePlatformPoolManager
extends Node

# Simplified platform manager without pooling

signal platform_created(platform: Node, platform_data: PlatformData)

func _ready():
	print("SimplePlatformPoolManager: Initialized")

# Create platforms for a complete level
func create_level_platforms(level_data: LevelData, parent_node: Node) -> Array:
	var created_platforms = []
	
	for platform_data in level_data.platforms:
		var platform = _create_platform_directly(platform_data)
		if platform:
			parent_node.add_child(platform)
			created_platforms.append(platform)
			platform_created.emit(platform, platform_data)
		else:
			print("SimplePlatformPoolManager: Failed to create platform")
	
	print("SimplePlatformPoolManager: Created ", created_platforms.size(), " platforms for level ", level_data.level_number)
	return created_platforms

# Clear all platforms for a level
func clear_level_platforms(platforms: Array):
	var cleared_count = 0
	
	for platform in platforms:
		if platform and is_instance_valid(platform):
			platform.queue_free()
			cleared_count += 1
	
	print("SimplePlatformPoolManager: Cleared ", cleared_count, " platforms from level")

# Create platform directly
func _create_platform_directly(platform_data: PlatformData) -> Node:
	var platform_scene = preload("res://Platform.tscn")
	var platform = platform_scene.instantiate()
	
	if platform and platform_data:
		# Set position
		platform.global_position = platform_data.position
		
		# Configure platform properties
		if platform.has_method("configure_platform"):
			platform.configure_platform(platform_data)
		else:
			# Default configuration
			platform.platform_color = platform_data.color
			platform.platform_size = platform_data.size
			platform.setup_platform()
	
	return platform

# Get basic statistics (placeholder)
func get_all_pool_statistics() -> Dictionary:
	return {
		"summary": {
			"total_pools": 0,
			"total_objects": 0,
			"total_active": 0,
			"total_available": 0,
			"total_created": 0,
			"total_recycled": 0,
			"hit_rate": 0.0
		}
	}