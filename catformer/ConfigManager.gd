extends Node

# ConfigManager - Singleton for managing game configuration
# Handles loading, saving, and runtime config changes

var config: GameConfig
var config_file_path: String = "user://game_config.tres"

func _ready():
	load_config()
	
	# Listen for config change events
	GameEventBus.config_changed.connect(_on_config_changed)
	
	print("ConfigManager initialized with config")

func load_config():
	# Try to load user config first, fall back to default
	if FileAccess.file_exists(config_file_path):
		config = GameConfig.load_from_file(config_file_path)
	else:
		config = GameConfig.load_default()
		save_config() # Save default config for future editing
	
	# Make config globally available
	GameConfig.current = config

func save_config():
	GameConfig.save_to_file(config, config_file_path)

func reload_config():
	print("ConfigManager: Reloading configuration...")
	load_config()
	GameEventBus.config_changed.emit("config_reloaded", true)

func get_config() -> GameConfig:
	return config

func set_config_value(property: String, value):
	if config.has_method("set"):
		config.set(property, value)
		config.notify_config_changed(property, value)
		save_config()

func _on_config_changed(property: String, new_value):
	# Handle config changes that require immediate action
	match property:
		"enable_debug_logging":
			print("Debug logging ", "enabled" if new_value else "disabled")
		"player_speed", "jump_velocity":
			print("Player physics updated: ", property, " = ", new_value)
		"config_reloaded":
			print("Configuration reloaded successfully")

# Debug function to print current config
func print_config():
	print("=== Current Game Configuration ===")
	print("Player Speed: ", config.player_speed)
	print("Jump Velocity: ", config.jump_velocity)
	print("Fall Death Y: ", config.fall_death_y)
	print("Platform Size: ", config.platform_size)
	print("Min Platform Spacing: ", config.min_platform_spacing)
	print("Platforms Per Level: ", config.min_platforms_per_level, "-", config.max_platforms_per_level)
	print("Debug Logging: ", config.enable_debug_logging)
	print("==================================")