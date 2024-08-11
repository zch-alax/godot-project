extends Node2D

@export var levels_map: Dictionary

var current_level

func load_level(level_name):
	current_level = load(levels_map[level_name]).instantiate()
	add_child(current_level)
	
func upload():
	current_level.queue_free()
	current_level = null
