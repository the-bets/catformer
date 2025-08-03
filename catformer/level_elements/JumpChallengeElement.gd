extends LevelElement
class_name JumpChallengeElement

# JumpChallengeElement - Specific jumping puzzles and challenges
# Creates focused skill-testing sections with multiple platform arrangements

enum ChallengeType {
	PRECISION_JUMPS,    # Small platforms requiring accuracy
	LONG_JUMPS,        # Maximum distance jumps
	VERTICAL_CLIMB,    # Upward jumping sequence
	TIMING_JUMPS,      # Platforms that require specific timing
	COMBO_JUMPS        # Multiple jump types combined
}

var challenge_type: ChallengeType
var platform_count: int

func _init(type: ChallengeType = ChallengeType.PRECISION_JUMPS, center_pos: Vector2 = Vector2(400, 350), count: int = 4):
	super._init(ElementType.JUMP_CHALLENGE, "JumpChallenge_" + _get_challenge_name(type))
	challenge_type = type
	platform_count = clamp(count, 3, 8)
	description = "A " + _get_challenge_name(type) + " challenge with " + str(platform_count) + " platforms"
	_build_challenge(center_pos)

func _build_challenge(center_pos: Vector2):
	match challenge_type:
		ChallengeType.PRECISION_JUMPS:
			_build_precision_jumps(center_pos)
		ChallengeType.LONG_JUMPS:
			_build_long_jumps(center_pos)
		ChallengeType.VERTICAL_CLIMB:
			_build_vertical_climb(center_pos)
		ChallengeType.TIMING_JUMPS:
			_build_timing_jumps(center_pos)
		ChallengeType.COMBO_JUMPS:
			_build_combo_jumps(center_pos)
	
	_update_challenge_properties()

func _build_precision_jumps(center_pos: Vector2):
	difficulty_rating = 0.7
	tags = ["precision", "accuracy", "challenge"]
	required_skills = ["precision_jumping"]
	
	var current_pos = center_pos + Vector2(-150, 50)
	
	for i in range(platform_count):
		var platform_size = Vector2(
			randi_range(64, 96),  # Small platforms
			24
		)
		var platform_color = Color(0.8, 0.4, 0.4, 1)  # Red for challenge
		
		add_platform(current_pos, platform_color, platform_size)
		
		# Next platform position - small gaps, some height variation
		current_pos += Vector2(
			randi_range(80, 120),  # Tight horizontal spacing
			randi_range(-30, 30)   # Small height variation
		)
	
	# Add connection points
	add_connection_point(center_pos + Vector2(-200, 50))  # Entry
	add_connection_point(current_pos + Vector2(50, 0))    # Exit

func _build_long_jumps(center_pos: Vector2):
	difficulty_rating = 0.6
	tags = ["distance", "long_jump", "challenge"]
	required_skills = ["basic_jump", "distance_jumping"]
	
	var current_pos = center_pos + Vector2(-200, 0)
	
	for i in range(platform_count):
		var platform_size = Vector2(128, 32)  # Normal sized platforms
		var platform_color = Color(0.4, 0.6, 0.8, 1)  # Blue for distance
		
		add_platform(current_pos, platform_color, platform_size)
		
		# Next platform - long horizontal gaps
		current_pos += Vector2(
			randi_range(130, 160),  # Near maximum jump distance
			randi_range(-40, 40)    # Some height variation
		)
	
	add_connection_point(center_pos + Vector2(-250, 0))
	add_connection_point(current_pos + Vector2(64, 0))

func _build_vertical_climb(center_pos: Vector2):
	difficulty_rating = 0.5
	tags = ["vertical", "climbing", "upward"]
	required_skills = ["basic_jump"]
	
	var current_pos = center_pos + Vector2(0, 100)  # Start at bottom
	
	for i in range(platform_count):
		var platform_size = Vector2(
			randi_range(100, 140),
			32
		)
		var platform_color = Color(0.4, 0.8, 0.4, 1)  # Green for climbing
		
		add_platform(current_pos, platform_color, platform_size)
		
		# Move up and slightly sideways
		var horizontal_offset = 80 if i % 2 == 0 else -80  # Zigzag pattern
		current_pos += Vector2(horizontal_offset, -70)  # Go up
	
	add_connection_point(center_pos + Vector2(0, 120))     # Bottom entry
	add_connection_point(current_pos + Vector2(0, -40))    # Top exit

func _build_timing_jumps(center_pos: Vector2):
	difficulty_rating = 0.8
	tags = ["timing", "rhythm", "advanced"]
	required_skills = ["timing", "precision_jumping"]
	
	var current_pos = center_pos + Vector2(-150, 0)
	
	for i in range(platform_count):
		var platform_size = Vector2(
			randi_range(80, 110),  # Medium-small platforms
			28
		)
		var platform_color = Color(0.8, 0.6, 0.2, 1)  # Orange for timing
		
		add_platform(current_pos, platform_color, platform_size)
		
		# Timing-based spacing - consistent rhythm
		current_pos += Vector2(110, sin(i * PI / 2) * 50)  # Sinusoidal pattern
	
	add_connection_point(center_pos + Vector2(-200, 0))
	add_connection_point(current_pos + Vector2(55, 0))

func _build_combo_jumps(center_pos: Vector2):
	difficulty_rating = 0.9
	tags = ["combo", "complex", "expert"]
	required_skills = ["precision_jumping", "distance_jumping", "timing"]
	
	var current_pos = center_pos + Vector2(-200, 0)
	
	# Mix different jump types
	for i in range(platform_count):
		var jump_type = i % 3
		var platform_color: Color
		var next_offset: Vector2
		var platform_size: Vector2
		
		match jump_type:
			0:  # Precision
				platform_size = Vector2(70, 24)
				platform_color = Color(0.8, 0.4, 0.4, 1)
				next_offset = Vector2(85, randi_range(-20, 20))
			1:  # Distance
				platform_size = Vector2(100, 32)
				platform_color = Color(0.4, 0.6, 0.8, 1)
				next_offset = Vector2(140, randi_range(-30, 30))
			2:  # Vertical
				platform_size = Vector2(120, 32)
				platform_color = Color(0.4, 0.8, 0.4, 1)
				next_offset = Vector2(90, -60)
		
		add_platform(current_pos, platform_color, platform_size)
		current_pos += next_offset
	
	add_connection_point(center_pos + Vector2(-250, 0))
	add_connection_point(current_pos + Vector2(60, 0))

func _update_challenge_properties():
	# Adjust difficulty based on platform count
	var count_modifier = (platform_count - 3) * 0.1  # +0.1 per extra platform
	difficulty_rating = clamp(difficulty_rating + count_modifier, 0.1, 1.0)
	
	# Update size based on actual bounds
	_update_bounds()

func _get_challenge_name(type: ChallengeType) -> String:
	match type:
		ChallengeType.PRECISION_JUMPS: return "Precision"
		ChallengeType.LONG_JUMPS: return "Distance"
		ChallengeType.VERTICAL_CLIMB: return "Vertical"
		ChallengeType.TIMING_JUMPS: return "Timing"
		ChallengeType.COMBO_JUMPS: return "Combo"
		_: return "Unknown"

# Validate challenge has appropriate difficulty progression
func validate() -> bool:
	if not super.validate():
		return false
	
	# Should have minimum platforms for a challenge
	if platforms.size() < 3:
		return false
	
	# Check that platforms form a reasonable progression
	for i in range(platforms.size() - 1):
		var current = platforms[i].position
		var next = platforms[i + 1].position
		var distance = current.distance_to(next)
		
		# Ensure jumps are within reasonable bounds
		if distance > 200 or distance < 50:  # Too far or too close
			return false
	
	return true