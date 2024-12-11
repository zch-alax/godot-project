extends Node2D

var arr = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

var events = arr.filter(func(num): return num % 2 == 0)
	
func _ready() -> void:
	print(events)
