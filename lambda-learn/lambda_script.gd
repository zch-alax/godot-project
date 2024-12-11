extends Node

func _ready() -> void:
	print(calculate(3, 10, func(num1, num2): return num1 + num2))
	print(calculate(3, 10, func(num1, num2): return num1 * num2))
	

func calculate(num1: int, num2: int, operation: Callable):
	return operation.call(num1, num2)
