class_name State

extends Node

var player = null

@onready var animated_sprite = %AnimatedSprite2D

func _ready():
	player = get_parent().get_parent()

func enter_condition() -> bool:
	return false

func update(delta: float) -> void:
	pass
	
func exit_condition() -> bool:
	return true
	
func on_enter() -> void:
	pass	
func on_exit() -> void:
	pass




