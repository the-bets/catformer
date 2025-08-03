extends Node

# Game Events - Centralized event system for decoupled communication
# This singleton manages all game events to avoid tight coupling between systems

# Level Events
signal level_completed(level_number: int)
signal level_loaded(level_data: LevelData)
signal level_created(level_data: LevelData, level_type: String, difficulty: float)

# Player Events  
signal player_reached_goal(player: CharacterBody2D, goal: Area2D)
signal player_died(death_position: Vector2)
signal player_respawned(spawn_position: Vector2)

# Platform Events
signal platform_created(platform: Node, platform_data: PlatformData)

# Config Events
signal config_changed(property: String, new_value)

# Generation Events
signal generation_strategy_used(level_number: int, strategy_name: String, difficulty_multiplier: float)

func _ready():
	print("GameEventBus initialized")

# Convenience methods for common events
func emit_level_completed(level_num: int):
	print("GameEventBus: Level ", level_num, " completed")
	level_completed.emit(level_num)

func emit_player_reached_goal(player: CharacterBody2D, goal: Area2D):
	print("GameEventBus: Player reached goal")
	player_reached_goal.emit(player, goal)

func emit_level_loaded(level_data: LevelData):
	print("GameEventBus: Level ", level_data.level_number, " loaded")
	level_loaded.emit(level_data)

func emit_level_created(level_data: LevelData, level_type: String, difficulty: float):
	print("GameEventBus: Level ", level_data.level_number, " created (Type: ", level_type, ", Difficulty: ", difficulty, ")")
	level_created.emit(level_data, level_type, difficulty)

func emit_platform_created(platform: Node, platform_data: PlatformData):
	platform_created.emit(platform, platform_data)

func emit_config_changed(property: String, new_value):
	config_changed.emit(property, new_value)

func emit_generation_strategy_used(level_number: int, strategy_name: String, difficulty_multiplier: float):
	generation_strategy_used.emit(level_number, strategy_name, difficulty_multiplier)