extends Node
class_name PlayerInput

# PlayerInput - Handles input processing and buffering
# Separated for easier input customization and testing

signal input_received(action: String, strength: float)
signal jump_requested()
signal movement_requested(direction: float)

# Input buffering for better game feel
var jump_buffer_time: float = 0.1
var jump_buffer_timer: float = 0.0

var config: GameConfig

func _ready():
	config = GameConfig.current

func _process(delta: float):
	config = GameConfig.current
	if not config:
		return
		
	# Update input buffers
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Handle jump input with buffering
	if Input.is_action_just_pressed("ui_accept"):
		var buffer_time = config.jump_buffer_time if config else jump_buffer_time
		jump_buffer_timer = buffer_time
		input_received.emit("jump", 1.0)
	
	# Emit jump request if buffer is active
	if jump_buffer_timer > 0:
		jump_requested.emit()
	
	# Handle movement input
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		input_received.emit("move", direction)
	movement_requested.emit(direction)

func consume_jump_buffer():
	"""Call this when jump is successfully executed to clear the buffer"""
	jump_buffer_timer = 0.0

func has_jump_buffered() -> bool:
	return jump_buffer_timer > 0

func get_movement_direction() -> float:
	return Input.get_axis("ui_left", "ui_right")

func is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("ui_accept")

func is_jump_held() -> bool:
	return Input.is_action_pressed("ui_accept")

func get_input_info() -> Dictionary:
	return {
		"movement_direction": get_movement_direction(),
		"jump_pressed": is_jump_pressed(),
		"jump_held": is_jump_held(),
		"jump_buffered": has_jump_buffered(),
		"jump_buffer_remaining": jump_buffer_timer
	}