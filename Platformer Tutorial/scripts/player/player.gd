class_name Player
extends CharacterBody2D

const MAX_SPEED = 120.0
const ACCELERATION = 900
const AIR_MULTPLER = 0.7
const JUMP_GRAVITY = 980.0
const FALL_GRAVITY = 600.0
const TERMINAL_VELOCITY = 400.0

var direction:
	get: return direction
	set(value):
		if value == 0 or value == direction:
			return value
		animated_sprite.flip_h = value == -1

@onready var animated_sprite = $AnimatedSprite2D
@onready var fsm = $FSM
@onready var input = $InputHandler

func _ready():
	fsm.change_state("idle")

func _physics_process(delta):
	input.update()
	fsm.physics_update(delta)
