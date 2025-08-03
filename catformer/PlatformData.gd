extends Resource
class_name PlatformData

@export var position: Vector2
@export var color: Color = Color(0.4, 0.8, 0.4, 1)
@export var size: Vector2 = Vector2(128, 32)

func _init(p_position: Vector2 = Vector2.ZERO, p_color: Color = Color(0.4, 0.8, 0.4, 1), p_size: Vector2 = Vector2(128, 32)):
	position = p_position
	color = p_color
	size = p_size