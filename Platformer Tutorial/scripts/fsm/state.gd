class_name State

extends Node

var object
var fsm

func enter() -> void:
	pass

func update(_delta) -> void:
	pass
	
func physics_update(_delta) -> void:
	pass
	
func exit() -> void:
	pass
	
func change_state(next_state) -> void:
	fsm.change_state(next_state)
