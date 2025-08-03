extends CharacterBody2D
class_name PlayerController

# PlayerController - Main player class using component system
# Clean separation of concerns for better maintainability

# Component references
@onready var movement_component: PlayerMovement = $PlayerMovement
@onready var input_component: PlayerInput = $PlayerInput  
@onready var respawn_component: PlayerRespawn = $PlayerRespawn

# Signals for other systems to listen to
signal state_changed(new_state: String)
signal died(position: Vector2, reason: String)
signal respawned(position: Vector2)

func _ready():
	# Connect component signals
	if movement_component:
		movement_component.movement_state_changed.connect(_on_movement_state_changed)
	
	if input_component:
		input_component.jump_requested.connect(_on_jump_requested)
		input_component.movement_requested.connect(_on_movement_requested)
	
	if respawn_component:
		respawn_component.player_died.connect(_on_player_died)
		respawn_component.player_respawned.connect(_on_player_respawned)

func _physics_process(delta: float):
	# Let movement component handle physics with input from input component
	if movement_component and input_component:
		var direction = input_component.get_movement_direction()
		var jump_requested = input_component.has_jump_buffered()
		movement_component.handle_physics(delta, direction, jump_requested)

func _on_jump_requested():
	# This is handled in _physics_process now, but kept for potential future use
	pass

func _on_movement_requested(_direction: float):
	# This is handled in _physics_process now, but kept for potential future use
	pass

func _on_movement_state_changed(new_state: String):
	state_changed.emit(new_state)

func _on_player_died(death_position: Vector2, reason: String):
	died.emit(death_position, reason)

func _on_player_respawned(spawn_position: Vector2):
	respawned.emit(spawn_position)

# Public API for other systems
func set_spawn_position(pos: Vector2):
	if respawn_component:
		respawn_component.set_spawn_position(pos)

func get_spawn_position() -> Vector2:
	return respawn_component.get_spawn_position() if respawn_component else Vector2.ZERO

func trigger_respawn():
	if respawn_component:
		respawn_component.respawn()

func get_movement_info() -> Dictionary:
	var info = {}
	if movement_component:
		info.merge(movement_component.get_movement_info())
	if input_component:
		info.merge(input_component.get_input_info())
	if respawn_component:
		info.merge(respawn_component.get_respawn_info())
	return info

func get_current_state() -> String:
	return movement_component.get_state_name(movement_component.current_state) if movement_component else "unknown"