extends Node
class_name LevelLoader

static func create_level_1() -> LevelData:
	var level = LevelData.new()
	level.level_number = 1
	level.player_spawn_position = Vector2(300, 500)
	level.goal_position = Vector2(700, 300)
	
	var platform1 = PlatformData.new()
	platform1.position = Vector2(200, 500)
	platform1.color = Color(0.4, 0.8, 0.4, 1)
	platform1.size = Vector2(128, 32)
	
	var platform2 = PlatformData.new()
	platform2.position = Vector2(400, 400)
	platform2.color = Color(0.4, 0.8, 0.4, 1)
	platform2.size = Vector2(128, 32)
	
	var platform3 = PlatformData.new()
	platform3.position = Vector2(600, 350)
	platform3.color = Color(0.4, 0.8, 0.4, 1)
	platform3.size = Vector2(128, 32)
	
	var ground = PlatformData.new()
	ground.position = Vector2(300, 550)
	ground.color = Color(0.6, 0.4, 0.2, 1)
	ground.size = Vector2(128, 32)
	
	level.platforms = [platform1, platform2, platform3, ground]
	return level

static func create_level_2() -> LevelData:
	var level = LevelData.new()
	level.level_number = 2
	level.player_spawn_position = Vector2(100, 500)
	level.goal_position = Vector2(650, 150)
	
	var ground = PlatformData.new()
	ground.position = Vector2(100, 550)
	ground.color = Color(0.6, 0.4, 0.2, 1)
	ground.size = Vector2(128, 32)
	
	var platform1 = PlatformData.new()
	platform1.position = Vector2(300, 450)
	platform1.color = Color(0.4, 0.8, 0.4, 1)
	platform1.size = Vector2(128, 32)
	
	var platform2 = PlatformData.new()
	platform2.position = Vector2(150, 350)
	platform2.color = Color(0.4, 0.8, 0.4, 1)
	platform2.size = Vector2(128, 32)
	
	var platform3 = PlatformData.new()
	platform3.position = Vector2(500, 300)
	platform3.color = Color(0.4, 0.8, 0.4, 1)
	platform3.size = Vector2(128, 32)
	
	var platform4 = PlatformData.new()
	platform4.position = Vector2(350, 200)
	platform4.color = Color(0.4, 0.8, 0.4, 1)
	platform4.size = Vector2(128, 32)
	
	level.platforms = [ground, platform1, platform2, platform3, platform4]
	return level

static func create_random_level(level_num: int) -> LevelData:
	var level = LevelData.new()
	level.level_number = level_num
	
	# Always start from the left
	level.player_spawn_position = Vector2(100, 450)
	
	# Create starting platform at spawn position
	var start_platform = PlatformData.new()
	start_platform.position = Vector2(100, 500)
	start_platform.color = Color(0.6, 0.4, 0.2, 1)
	start_platform.size = Vector2(128, 32)
	level.platforms.append(start_platform)
	
	# Smart platform generation with rules
	var current_pos = start_platform.position
	var platform_count = randi_range(4, 7)
	var difficulty = min(level_num - 2, 8) / 8.0  # Scale difficulty 0-1 for levels 3+
	
	for i in range(platform_count):
		var platform_size = Vector2(randi_range(100, 150), 32)
		var next_pos = _generate_reachable_platform_position(current_pos, level.platforms, difficulty, platform_size)
		
		var platform = PlatformData.new()
		platform.position = next_pos
		platform.color = Color(randf_range(0.3, 0.8), randf_range(0.3, 0.8), randf_range(0.3, 0.8), 1)
		platform.size = platform_size
		level.platforms.append(platform)
		
		current_pos = next_pos
	
	# Place goal reachable from the last platform
	level.goal_position = _generate_reachable_goal_position(current_pos, level.platforms)
	
	return level

static func _generate_reachable_platform_position(from_pos: Vector2, existing_platforms: Array, difficulty: float, platform_size: Vector2 = Vector2(128, 32)) -> Vector2:
	var max_horizontal = 130  # Safe horizontal jump distance
	var max_vertical_up = 90   # Safe vertical jump up
	var max_vertical_down = 200 # Can fall further down
	
	# Increase challenge with difficulty
	var min_gap = 80 + int(difficulty * 40)  # Minimum gap gets larger
	var height_variation = 60 + int(difficulty * 80)  # More height variation
	
	var attempts = 0
	while attempts < 20:  # Prevent infinite loops
		var horizontal_dir = 1 if randf() > 0.2 else -1  # Mostly go right, sometimes left
		var horizontal_distance = randi_range(min_gap, max_horizontal)
		var vertical_distance = randi_range(-max_vertical_up, max_vertical_down)
		
		# Add some randomness but keep it reachable
		if difficulty > 0.5:
			vertical_distance = randi_range(-height_variation, height_variation/2)
		
		var next_pos = Vector2(
			from_pos.x + horizontal_distance * horizontal_dir,
			from_pos.y + vertical_distance
		)
		
		# Keep on screen
		next_pos.x = clamp(next_pos.x, 150, 750)
		next_pos.y = clamp(next_pos.y, 150, 550)
		
		# Check if position doesn't overlap with existing platforms
		if _is_position_valid(next_pos, existing_platforms, platform_size):
			return next_pos
		
		attempts += 1
	
	# Fallback: safe position to the right
	return Vector2(
		clamp(from_pos.x + 120, 150, 750),
		clamp(from_pos.y + randi_range(-50, 50), 150, 550)
	)

static func _generate_reachable_goal_position(from_pos: Vector2, existing_platforms: Array) -> Vector2:
	# Goal should be reachable but not too easy
	var goal_pos = Vector2(
		from_pos.x + randi_range(80, 120),
		from_pos.y + randi_range(-80, -20)  # Slightly above for challenge
	)
	
	# Keep on screen
	goal_pos.x = clamp(goal_pos.x, 200, 800)
	goal_pos.y = clamp(goal_pos.y, 100, 400)
	
	return goal_pos

static func _is_position_valid(pos: Vector2, existing_platforms: Array, new_platform_size: Vector2 = Vector2(128, 32)) -> bool:
	var min_spacing = 80   # Minimum gap between any platforms (no touching!)
	var min_jump_gap = 140 # Minimum gap needed for jumping between platforms
	
	for platform in existing_platforms:
		var platform_size = platform.size if platform is PlatformData else Vector2(128, 32)
		
		# Calculate distance between platform edges (not centers)
		var new_rect = Rect2(pos - new_platform_size/2, new_platform_size)
		var existing_rect = Rect2(platform.position - platform_size/2, platform_size)
		
		# Check minimum spacing - platforms must never be closer than min_spacing
		var horizontal_distance = _get_rect_horizontal_distance(new_rect, existing_rect)
		var vertical_distance = _get_rect_vertical_distance(new_rect, existing_rect)
		
		# Enforce minimum spacing in all directions
		if horizontal_distance < min_spacing or vertical_distance < min_spacing:
			return false
		
		# For platforms at similar heights, enforce larger jump gap
		if vertical_distance < 60:  # Similar height
			if horizontal_distance < min_jump_gap:
				return false
	
	# Check if this placement maintains vertical traversability
	if not _maintains_vertical_paths(pos, new_platform_size, existing_platforms):
		return false
	
	return true

static func _get_rect_horizontal_distance(rect1: Rect2, rect2: Rect2) -> float:
	if rect1.intersects(rect2):
		return 0
	
	var left_gap = rect1.position.x - (rect2.position.x + rect2.size.x)
	var right_gap = rect2.position.x - (rect1.position.x + rect1.size.x)
	
	return max(left_gap, right_gap)

static func _get_rect_vertical_distance(rect1: Rect2, rect2: Rect2) -> float:
	if rect1.intersects(rect2):
		return 0
	
	var top_gap = rect1.position.y - (rect2.position.y + rect2.size.y)
	var bottom_gap = rect2.position.y - (rect1.position.y + rect1.size.y)
	
	return max(top_gap, bottom_gap)

static func _creates_horizontal_wall(pos: Vector2, platform_size: Vector2, existing_platforms: Array, min_gap: float) -> bool:
	# Check if this platform creates a horizontal barrier that blocks vertical movement
	var barrier_height_range = 150  # Platforms within this height range can form a barrier
	var max_barrier_width = 250     # Maximum width of blocking barrier before we need a gap
	var min_traversal_gap = 140      # Minimum gap needed to jump through/around
	
	# Find all platforms that could contribute to a horizontal barrier
	var nearby_platforms = []
	for platform in existing_platforms:
		var height_diff = abs(platform.position.y - pos.y)
		var horizontal_distance = abs(platform.position.x - pos.x)
		
		# Include platforms that are close enough to potentially form a barrier
		if height_diff <= barrier_height_range and horizontal_distance <= max_barrier_width:
			nearby_platforms.append(platform)
	
	# If no nearby platforms, it's safe
	if nearby_platforms.size() == 0:
		return false
	
	# Add the new platform to check the resulting barrier
	var new_platform_data = {"position": pos, "size": platform_size}
	nearby_platforms.append(new_platform_data)
	
	# Sort by x position
	nearby_platforms.sort_custom(func(a, b): return a.position.x < b.position.x)
	
	# Check if this creates a continuous barrier without adequate gaps
	var total_coverage = 0
	var leftmost_pos = null
	var rightmost_pos = null
	var gaps = []
	
	for i in range(nearby_platforms.size()):
		var plat = nearby_platforms[i]
		var plat_size = plat.size if (plat is PlatformData or plat.has("size")) else platform_size
		var plat_left = plat.position.x - plat_size.x/2
		var plat_right = plat.position.x + plat_size.x/2
		
		if leftmost_pos == null:
			leftmost_pos = plat_left
			rightmost_pos = plat_right
		else:
			# Check gap to previous platform
			var gap_size = plat_left - rightmost_pos
			if gap_size > 0:
				gaps.append(gap_size)
			
			rightmost_pos = max(rightmost_pos, plat_right)
	
	# Calculate total barrier width
	var barrier_width = rightmost_pos - leftmost_pos
	
	# If barrier is wide and has no adequate gaps, it's blocking
	if barrier_width > max_barrier_width:
		var has_adequate_gap = false
		for gap in gaps:
			if gap >= min_traversal_gap:
				has_adequate_gap = true
				break
		
		if not has_adequate_gap:
			return true  # This creates a blocking horizontal barrier
	
	return false

static func _creates_vertical_stack(pos: Vector2, platform_size: Vector2, existing_platforms: Array) -> bool:
	var min_jump_clearance = 120  # Player needs this much vertical space to jump over
	var horizontal_overlap_tolerance = 50  # How much horizontal overlap constitutes "stacking"
	
	for platform in existing_platforms:
		var platform_size_existing = platform.size if platform is PlatformData else Vector2(128, 32)
		
		# Check if platforms overlap horizontally (are "stacked")
		var new_left = pos.x - platform_size.x/2
		var new_right = pos.x + platform_size.x/2
		var existing_left = platform.position.x - platform_size_existing.x/2
		var existing_right = platform.position.x + platform_size_existing.x/2
		
		# Check for horizontal overlap
		var horizontal_overlap = min(new_right, existing_right) - max(new_left, existing_left)
		
		if horizontal_overlap > horizontal_overlap_tolerance:
			# Platforms overlap horizontally - check vertical spacing
			var vertical_gap = abs(pos.y - platform.position.y)
			var combined_height = (platform_size.y + platform_size_existing.y) / 2
			var actual_gap = vertical_gap - combined_height
			
			# If vertical gap is too small, this creates an unpassable stack
			if actual_gap > 0 and actual_gap < min_jump_clearance:
				return true  # This would create a blocking vertical stack
	
	return false

static func _maintains_vertical_paths(pos: Vector2, platform_size: Vector2, existing_platforms: Array) -> bool:
	# Ensure there are always paths for vertical movement
	var screen_width = 800
	var path_width = 160  # Minimum width needed for a traversable path
	var check_height_above = pos.y - 120  # Check area above this platform
	var check_height_below = pos.y + 120  # Check area below this platform
	
	# Create test rectangles for the new platform
	var new_rect = Rect2(pos - platform_size/2, platform_size)
	
	# Check if this platform would block all vertical paths in a region
	var blocking_zones = []
	
	# Add the new platform as a potential blocking zone
	var new_zone = {
		"left": new_rect.position.x,
		"right": new_rect.position.x + new_rect.size.x,
		"top": min(check_height_above, new_rect.position.y),
		"bottom": max(check_height_below, new_rect.position.y + new_rect.size.y)
	}
	blocking_zones.append(new_zone)
	
	# Add existing platforms that could contribute to blocking
	for platform in existing_platforms:
		var platform_size_existing = platform.size if platform is PlatformData else Vector2(128, 32)
		var plat_rect = Rect2(platform.position - platform_size_existing/2, platform_size_existing)
		
		# Only consider platforms that are vertically close to our area of interest
		if plat_rect.position.y < check_height_below and (plat_rect.position.y + plat_rect.size.y) > check_height_above:
			var platform_zone = {
				"left": plat_rect.position.x,
				"right": plat_rect.position.x + plat_rect.size.x,
				"top": min(check_height_above, plat_rect.position.y),
				"bottom": max(check_height_below, plat_rect.position.y + plat_rect.size.y)
			}
			blocking_zones.append(platform_zone)
	
	# Sort zones by left edge
	blocking_zones.sort_custom(func(a, b): return a.left < b.left)
	
	# Check if there are adequate gaps for vertical traversal
	var screen_left = 100
	var screen_right = 700
	var current_pos = screen_left
	
	for zone in blocking_zones:
		# Check gap before this zone
		var gap_width = zone.left - current_pos
		if gap_width >= path_width:
			return true  # Found an adequate vertical path
		
		current_pos = max(current_pos, zone.right)
	
	# Check final gap to right edge of screen
	var final_gap = screen_right - current_pos
	if final_gap >= path_width:
		return true  # Found an adequate vertical path
	
	return false  # No adequate vertical paths found