@icon("res://icon.svg")

extends Node2D

class_name MyNode

@export var a: int = 1
@export var b: String

func _ready():
	print("my custom node")
	$"../Button2".connect("pressed", Callable(self, "_on_button2_pressed"))
	pass

func _on_button_pressed(): 
	print("this is button pressed!")
	pass

func _on_button2_pressed():
	print("this is button2 pressed!")
	pass
