# File: Player.gd
extends CharacterBody2D
var is_floor = false


@export var gravity :float= 980.0
@export var speed: float = 200.0


@onready var fsm = $FSM

func _physics_process(delta):
	fsm._physics_process(delta)
	move_and_slide()
	

