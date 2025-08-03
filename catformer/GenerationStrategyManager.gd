extends Node
class_name GenerationStrategyManager

# GenerationStrategyManager - Manages and selects level generation strategies
# Implements the Strategy Pattern context for flexible level generation

enum StrategyType {
	LINEAR_PROGRESSION,
	ZIGZAG,
	SPIRAL,
	SMART_PLACEMENT,
	MODULAR,
	RANDOM_CHOICE
}

# Available strategies (lazy-loaded)
var _strategies: Dictionary = {}
var _current_strategy: LevelGenerationStrategy

# Strategy selection preferences (loaded from config)
var _strategy_weights: Dictionary = {}

func _ready():
	initialize()

# Public initialization method that can be called manually
func initialize():
	_initialize_strategies()
	_load_strategy_weights_from_config()

# Initialize all available strategies
func _initialize_strategies():
	_strategies[StrategyType.LINEAR_PROGRESSION] = LinearProgressionStrategy.new()
	_strategies[StrategyType.ZIGZAG] = ZigzagStrategy.new()
	_strategies[StrategyType.SPIRAL] = SpiralStrategy.new()
	_strategies[StrategyType.SMART_PLACEMENT] = SmartPlacementStrategy.new()
	_strategies[StrategyType.MODULAR] = ModularStrategy.new()
	
	# Set default strategy
	_current_strategy = _strategies[StrategyType.SMART_PLACEMENT]

# Main generation method - selects and uses appropriate strategy
func generate_level(level_number: int, suggested_strategy: StrategyType = StrategyType.RANDOM_CHOICE) -> LevelData:
	var config = GameConfig.current
	var strategy_to_use = _select_strategy(level_number, suggested_strategy, config)
	
	# Generate level using selected strategy
	var level_data = strategy_to_use.generate_level(level_number, config)
	
	# Validate the generated level
	if not strategy_to_use.validate_level(level_data, config):
		print("Warning: Generated level failed validation, falling back to SmartPlacement")
		strategy_to_use = _strategies[StrategyType.SMART_PLACEMENT]
		level_data = strategy_to_use.generate_level(level_number, config)
	
	# Emit generation event
	var strategy_name = strategy_to_use.get_strategy_name()
	var difficulty_multiplier = strategy_to_use.get_difficulty_multiplier()
	GameEventBus.emit_generation_strategy_used(level_number, strategy_name, difficulty_multiplier)
	
	return level_data

# Select the most appropriate strategy for the given context
func _select_strategy(level_number: int, suggested_strategy: StrategyType, config: GameConfig) -> LevelGenerationStrategy:
	if suggested_strategy != StrategyType.RANDOM_CHOICE:
		return _strategies[suggested_strategy]
	
	# Auto-select based on level number and progression
	var strategy_type = _get_strategy_for_level_progression(level_number, config)
	return _strategies[strategy_type]

# Determine strategy based on level progression and player experience
func _get_strategy_for_level_progression(level_number: int, config: GameConfig) -> StrategyType:
	var tutorial_count = config.tutorial_levels_count if config else 1
	var standard_count = config.standard_levels_count if config else 4
	
	# Early levels: use simpler strategies
	if level_number <= tutorial_count + 2:
		return StrategyType.LINEAR_PROGRESSION
	
	# Mid-game: introduce variety
	elif level_number <= tutorial_count + standard_count + 5:
		return _weighted_random_selection([
			StrategyType.LINEAR_PROGRESSION,
			StrategyType.ZIGZAG,
			StrategyType.SMART_PLACEMENT
		])
	
	# Late game: use all strategies with emphasis on complex ones
	else:
		return _weighted_random_selection([
			StrategyType.ZIGZAG,
			StrategyType.SPIRAL,
			StrategyType.SMART_PLACEMENT,
			StrategyType.MODULAR
		])

# Select a strategy using weighted random selection
func _weighted_random_selection(available_strategies: Array[StrategyType]) -> StrategyType:
	var total_weight = 0.0
	for strategy_type in available_strategies:
		total_weight += _strategy_weights.get(strategy_type, 1.0)
	
	var random_value = randf() * total_weight
	var cumulative_weight = 0.0
	
	for strategy_type in available_strategies:
		cumulative_weight += _strategy_weights.get(strategy_type, 1.0)
		if random_value <= cumulative_weight:
			return strategy_type
	
	# Fallback
	return available_strategies[0]

# Manual strategy selection (for testing or special cases)
func set_strategy(strategy_type: StrategyType):
	if strategy_type in _strategies:
		_current_strategy = _strategies[strategy_type]
		print("GenerationStrategyManager: Strategy set to ", _current_strategy.get_strategy_name())
	else:
		print("Error: Unknown strategy type: ", strategy_type)

# Get current strategy info
func get_current_strategy_info() -> Dictionary:
	return {
		"name": _current_strategy.get_strategy_name(),
		"difficulty_multiplier": _current_strategy.get_difficulty_multiplier()
	}

# Get all available strategies info
func get_available_strategies() -> Array[Dictionary]:
	var strategies_info = []
	for strategy_type in _strategies:
		var strategy = _strategies[strategy_type]
		strategies_info.append({
			"type": strategy_type,
			"name": strategy.get_strategy_name(),
			"difficulty_multiplier": strategy.get_difficulty_multiplier(),
			"weight": _strategy_weights.get(strategy_type, 1.0)
		})
	return strategies_info

# Update strategy weights (for dynamic difficulty adjustment)
func update_strategy_weight(strategy_type: StrategyType, new_weight: float):
	_strategy_weights[strategy_type] = max(0.0, new_weight)
	print("GenerationStrategyManager: Updated weight for ", strategy_type, " to ", new_weight)

# Generate multiple levels for comparison/testing
func generate_level_variants(level_number: int, count: int = 3) -> Array[LevelData]:
	var variants = []
	var available_strategies = [
		StrategyType.LINEAR_PROGRESSION,
		StrategyType.ZIGZAG,
		StrategyType.SPIRAL,
		StrategyType.SMART_PLACEMENT,
		StrategyType.MODULAR
	]
	
	for i in range(count):
		var strategy_type = available_strategies[i % available_strategies.size()]
		var strategy = _strategies[strategy_type]
		var level_data = strategy.generate_level(level_number, GameConfig.current)
		variants.append(level_data)
	
	return variants

# Load strategy weights from GameConfig
func _load_strategy_weights_from_config():
	var config = GameConfig.current
	if not config:
		# Use default weights
		_strategy_weights = {
			StrategyType.LINEAR_PROGRESSION: 1.0,
			StrategyType.ZIGZAG: 1.0,
			StrategyType.SPIRAL: 0.7,
			StrategyType.SMART_PLACEMENT: 1.2,
			StrategyType.MODULAR: 1.0
		}
		return
	
	_strategy_weights = {
		StrategyType.LINEAR_PROGRESSION: config.preferred_strategy_linear_weight,
		StrategyType.ZIGZAG: config.preferred_strategy_zigzag_weight,
		StrategyType.SPIRAL: config.preferred_strategy_spiral_weight,
		StrategyType.SMART_PLACEMENT: config.preferred_strategy_smart_weight,
		StrategyType.MODULAR: 1.0  # Use default weight for modular
	}
	
	print("GenerationStrategyManager: Loaded strategy weights from config")