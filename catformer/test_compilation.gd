# Quick compilation test script to check if our fixes work
extends Node

func _ready():
	print("Testing compilation fixes...")
	
	# Test GameEventBus signals
	if GameEventBus.has_signal("player_died"):
		print("✓ player_died signal exists")
	else:
		print("✗ player_died signal missing")
		
	if GameEventBus.has_signal("player_respawned"):
		print("✓ player_respawned signal exists")
	else:
		print("✗ player_respawned signal missing")
		
	if GameEventBus.has_signal("generation_strategy_used"):
		print("✓ generation_strategy_used signal exists")
	else:
		print("✗ generation_strategy_used signal missing")
	
	# Test if methods exist
	if GameEventBus.has_method("emit_generation_strategy_used"):
		print("✓ emit_generation_strategy_used method exists")
	else:
		print("✗ emit_generation_strategy_used method missing")
	
	print("Compilation test complete!")