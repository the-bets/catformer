extends Resource
class_name LevelData

@export var level_number: int
@export var player_spawn_position: Vector2
@export var platforms: Array = []
@export var goal_position: Vector2

func _init(p_level_number: int = 1, p_player_spawn: Vector2 = Vector2.ZERO, p_goal_pos: Vector2 = Vector2.ZERO):
	level_number = p_level_number
	player_spawn_position = p_player_spawn
	goal_position = p_goal_pos