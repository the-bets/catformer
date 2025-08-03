class_name SimpleObjectPool
extends RefCounted

# Simple object pool for testing
var pool_name: String
var available_objects = []
var active_objects = []
var preload_scene: PackedScene

func _init(name: String, scene: PackedScene):
	pool_name = name
	preload_scene = scene
	_initialize_pool()

func _initialize_pool():
	for i in range(10):
		var obj = preload_scene.instantiate()
		if obj:
			available_objects.append(obj)

func get_object():
	if available_objects.size() > 0:
		var obj = available_objects.pop_back()
		active_objects.append(obj)
		
		# Make sure object is removed from any parent before returning
		if obj.get_parent():
			obj.get_parent().remove_child(obj)
		
		# Call pooling lifecycle method if available
		if obj.has_method("_on_pooled_object_retrieved"):
			obj._on_pooled_object_retrieved()
		
		return obj
	return null

func return_object(obj):
	var index = active_objects.find(obj)
	if index != -1:
		# Remove from parent before returning to pool
		if obj.get_parent():
			obj.get_parent().remove_child(obj)
		
		# Call pooling lifecycle method if available
		if obj.has_method("_on_pooled_object_returned"):
			obj._on_pooled_object_returned()
		
		active_objects.remove_at(index)
		available_objects.append(obj)
		return true
	return false