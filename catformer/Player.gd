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
	if global_position.y > Constants.FALL_DEATH_Y:
		respawn()
		return
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = Constants.PLAYER_JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * Constants.PLAYER_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, Constants.PLAYER_SPEED)

	move_and_slide()

func respawn():
	global_position = spawn_position
	velocity = Vector2.ZERO