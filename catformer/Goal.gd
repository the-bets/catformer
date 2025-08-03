extends Area2D
class_name Goal

signal goal_reached(body)

func _ready():
	# Create visual representation
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(128, 32)
	color_rect.position = Vector2(-64, -16)
	color_rect.color = Constants.COLOR_GOAL
	add_child(color_rect)
	
	# Create collision shape
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(128, 32)
	collision_shape.shape = shape
	add_child(collision_shape)
	
	# Connect signal
	body_entered.connect(_on_body_entered)
	print("Goal ready with collision detection")

func _on_body_entered(body):
	print("Goal touched by: ", body.name)
	if body.name == "Player":
		print("Player reached goal! Emitting signal...")
		goal_reached.emit(body)