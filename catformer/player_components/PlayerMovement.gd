extends Node
class_name PlayerMovement

# PlayerMovement - Handles physics-based movement logic
# Separated from input handling for better testing and modularity

signal movement_state_changed(state: String)

enum MovementState { GROUNDED, AIRBORNE, FALLING }
var current_state: MovementState = MovementState.AIRBORNE

var player: CharacterBody2D
var config: GameConfig

func _ready():
	player = get_parent() as CharacterBody2D
	if not player:
		push_error("PlayerMovement must be child of CharacterBody2D")

func handle_physics(delta: float, input_direction: float, jump_requested: bool):
	config = GameConfig.current
	if not config:
		return
	
	# Update movement state
	update_movement_state()
	
	# Apply gravity
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
	# Handle jumping
	if jump_requested and can_jump():
		jump()
		# Let the input component know jump was consumed
		var input_component = player.get_node("PlayerInput")
		if input_component:
			input_component.consume_jump_buffer()
	
	# Handle horizontal movement
	handle_horizontal_movement(input_direction)
	
	# Apply movement
	player.move_and_slide()

func update_movement_state():
	var new_state: MovementState
	
	if player.is_on_floor():
		new_state = MovementState.GROUNDED
	elif player.velocity.y > 0.0:
		new_state = MovementState.FALLING
	else:
		new_state = MovementState.AIRBORNE
	
	if new_state != current_state:
		current_state = new_state
		movement_state_changed.emit(get_state_name(current_state))

func can_jump() -> bool:
	return player.is_on_floor()

func jump():
	var jump_velocity = config.jump_velocity if config else -550.0
	player.velocity.y = jump_velocity

func handle_horizontal_movement(direction: float):
	var player_speed = config.player_speed if config else 300.0
	if direction != 0.0:
		player.velocity.x = direction * player_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player_speed)

func get_state_name(state: MovementState) -> String:
	match state:
		MovementState.GROUNDED:
			return "grounded"
		MovementState.AIRBORNE:
			return "airborne"
		MovementState.FALLING:
			return "falling"
		_:
			return "unknown"

func get_movement_info() -> Dictionary:
	return {
		"state": get_state_name(current_state),
		"velocity": player.velocity,
		"is_on_floor": player.is_on_floor(),
		"speed": config.player_speed if config else 0.0,
		"jump_velocity": config.jump_velocity if config else 0.0
	}