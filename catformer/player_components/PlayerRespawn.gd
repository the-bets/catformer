extends Node
class_name PlayerRespawn

# PlayerRespawn - Handles death detection and respawn logic
# Separated for easier testing and customization

signal player_died(death_position: Vector2, death_reason: String)
signal player_respawned(spawn_position: Vector2)
signal spawn_position_set(position: Vector2)

var player: CharacterBody2D
var spawn_position: Vector2
var config: GameConfig

# Death detection
var death_zones: Array[String] = ["fall_death"]
var respawn_delay: float = 0.0

func _ready():
	player = get_parent() as CharacterBody2D
	if not player:
		push_error("PlayerRespawn must be child of CharacterBody2D")
	
	# Set initial spawn position
	spawn_position = player.global_position
	
	# Listen for config changes
	GameEventBus.config_changed.connect(_on_config_changed)

func _process(_delta: float):
	config = GameConfig.current
	if not config:
		return
		
	check_death_conditions()

func check_death_conditions():
	# Check fall death
	var fall_death_y = config.fall_death_y if config else 800.0
	if player.global_position.y > fall_death_y:
		trigger_death("fall_death")

func trigger_death(reason: String):
	var death_pos = player.global_position
	player_died.emit(death_pos, reason)
	GameEventBus.player_died.emit(death_pos)
	
	# Handle respawn delay
	if respawn_delay > 0:
		await get_tree().create_timer(respawn_delay).timeout
	
	respawn()

func respawn():
	player.global_position = spawn_position
	player.velocity = Vector2.ZERO
	
	player_respawned.emit(spawn_position)
	GameEventBus.player_respawned.emit(spawn_position)

func set_spawn_position(pos: Vector2):
	spawn_position = pos
	player.global_position = pos
	spawn_position_set.emit(pos)

func get_spawn_position() -> Vector2:
	return spawn_position

func add_death_zone(zone_name: String):
	if zone_name not in death_zones:
		death_zones.append(zone_name)

func remove_death_zone(zone_name: String):
	death_zones.erase(zone_name)

func _on_config_changed(property: String, new_value):
	if property == "respawn_delay":
		respawn_delay = new_value

func get_respawn_info() -> Dictionary:
	return {
		"spawn_position": spawn_position,
		"current_position": player.global_position,
		"death_zones": death_zones,
		"respawn_delay": respawn_delay,
		"fall_death_y": config.fall_death_y if config else 800.0
	}