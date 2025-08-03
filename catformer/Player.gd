extends CharacterBody2D

var spawn_position: Vector2

func _ready():
	if spawn_position == Vector2.ZERO:
		spawn_position = Vector2(300, 500)
	if global_position == Vector2.ZERO:
		global_position = spawn_position

func set_spawn_position(pos: Vector2):
	spawn_position = pos
	global_position = pos

func _physics_process(delta: float) -> void:
	# Use config values with fallbacks
	var fall_death_y = GameConfig.current.fall_death_y if GameConfig.current else 800.0
	var jump_velocity = GameConfig.current.jump_velocity if GameConfig.current else -550.0
	var player_speed = GameConfig.current.player_speed if GameConfig.current else 300.0
	
	if global_position.y > fall_death_y:
		respawn()
		return
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)

	move_and_slide()

func respawn():
	# Emit death event before respawning
	GameEventBus.player_died.emit(global_position)
	
	global_position = spawn_position
	velocity = Vector2.ZERO
	
	# Emit respawn event
	GameEventBus.player_respawned.emit(spawn_position)