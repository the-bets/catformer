extends Resource
class_name GameConfig

# GameConfig - Flexible, designer-friendly configuration system
# This replaces the rigid Constants.gd with tweakable parameters

@export_group("Player Movement")
@export var player_speed: float = 300.0
@export var jump_velocity: float = -550.0
@export var fall_death_y: float = 800.0
@export var coyote_time: float = 0.1  # Grace period for jumping after leaving platform
@export var jump_buffer_time: float = 0.1  # Grace period for jump input before landing

@export_group("Platform Properties")
@export var platform_size: Vector2 = Vector2(128, 32)
@export var platform_visual_size: Vector2 = Vector2(64, 16)
@export var min_platform_spacing: float = 80.0
@export var min_jump_gap: float = 140.0

@export_group("Visual Styling")
@export var color_player: Color = Color(0.8, 0.4, 0.8, 1)
@export var color_platform: Color = Color(0.4, 0.8, 0.4, 1)
@export var color_ground: Color = Color(0.6, 0.4, 0.2, 1)
@export var color_goal: Color = Color(1, 0.8, 0, 1)
@export var level_label_font_size: int = 24

@export_group("Level Generation")
@export var min_platforms_per_level: int = 4
@export var max_platforms_per_level: int = 7
@export var difficulty_scaling_rate: float = 0.125  # How much difficulty increases per level
@export var max_difficulty_level: int = 10  # Level cap for difficulty scaling
@export var platform_size_variance: Vector2 = Vector2(100, 150)  # Min/max platform widths

@export_group("Generation Rules")
@export var max_horizontal_jump: float = 130.0
@export var max_vertical_jump_up: float = 90.0
@export var max_vertical_jump_down: float = 200.0
@export var min_vertical_path_width: float = 160.0
@export var max_barrier_width: float = 250.0
@export var min_jump_clearance: float = 120.0

@export_group("Level Factory")
@export var tutorial_levels_count: int = 1  # How many tutorial levels
@export var standard_levels_count: int = 4  # How many hand-crafted standard levels
@export var challenge_level_frequency: int = 5  # Every Nth level is a challenge
@export var challenge_platform_size_multiplier: float = 0.8  # Smaller platforms in challenges
@export var challenge_gap_multiplier: float = 0.9  # Tighter gaps in challenges

@export_group("Generation Strategies")
@export var preferred_strategy_linear_weight: float = 1.0  # Weight for LinearProgression strategy
@export var preferred_strategy_zigzag_weight: float = 1.0  # Weight for Zigzag strategy
@export var preferred_strategy_spiral_weight: float = 0.7  # Weight for Spiral strategy
@export var preferred_strategy_smart_weight: float = 1.2   # Weight for SmartPlacement strategy
@export var enable_strategy_variety: bool = true  # Allow multiple strategies per session
@export var strategy_difficulty_scaling: bool = true  # Scale strategy difficulty with level

@export_group("Object Pooling")
@export var enable_object_pooling: bool = true  # Enable/disable object pooling system
@export var initial_platform_pool_size: int = 15  # Initial platforms per pool
@export var max_platform_pool_size: int = 50  # Maximum platforms per pool
@export var auto_expand_pools: bool = true  # Automatically expand pools when needed
@export var pool_optimization_frequency: int = 5  # Optimize pools every N levels

@export_group("Game Flow")
@export var respawn_delay: float = 0.0
@export var level_transition_delay: float = 0.5
@export var enable_debug_logging: bool = true

# Default configuration instance
static var current: GameConfig

static func load_default() -> GameConfig:
	var config = GameConfig.new()
	current = config
	return config

static func load_from_file(path: String) -> GameConfig:
	var config = load(path) as GameConfig
	if config:
		current = config
		if current.enable_debug_logging:
			print("GameConfig loaded from: ", path)
		return config
	else:
		print("Failed to load config from: ", path, " - using default")
		return load_default()

static func save_to_file(config: GameConfig, path: String) -> bool:
	var result = ResourceSaver.save(config, path)
	if result == OK:
		if config.enable_debug_logging:
			print("GameConfig saved to: ", path)
		return true
	else:
		print("Failed to save config to: ", path)
		return false

# Emit config change events through the event bus
func notify_config_changed(property: String, new_value):
	if enable_debug_logging:
		print("GameConfig: ", property, " changed to ", new_value)
	GameEventBus.config_changed.emit(property, new_value)