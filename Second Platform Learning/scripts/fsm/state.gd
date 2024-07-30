extends Node
class_name State

# 抽象状态类，抽象几个方法

var object
var fsm

func enter():
	pass

func update(_delta):
	pass

func physics_update(_delta):
	pass

func exit():
	pass

func change_state(next_state):
	pass
