extends StaticBody2D
class_name Platform

@export var platform_color: Color = Constants.COLOR_PLATFORM
@export var platform_size: Vector2 = Constants.PLATFORM_SIZE

func _ready():
	setup_platform()

func setup_platform():
	var collision_shape = $CollisionShape2D
	var color_rect = $ColorRect
	
	collision_shape.shape.size = platform_size
	color_rect.color = platform_color
	
	var visual_size = platform_size / 2
	color_rect.offset_left = -visual_size.x
	color_rect.offset_top = -visual_size.y
	color_rect.offset_right = visual_size.x
	color_rect.offset_bottom = visual_size.y