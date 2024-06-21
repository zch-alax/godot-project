class_name Player
extends CharacterBody2D

const MAX_SPEED = 120.0
const ACCELERATION = 900
const AIR_MULTPLER = 0.7
const JUMP_GRAVITY = 980.0
const FALL_GRAVITY = 500.0
const TERMINAL_VELOCITY = 200.0

var sword = false:
	get: return sword
	set(value):
		if sword == value:
			return
		sword = value
		var current_anim = animated_sprite.animation
		var target_anim = current_anim
		if value:
			target_anim += "_sword"
		else:
			target_anim = target_anim.replace("_sword", "")
		
		if animated_sprite.sprite_frames.has_animation(target_anim):
			var frame = animated_sprite.frame
			var process = animated_sprite.frame_progress
			animated_sprite.play(target_anim)
			animated_sprite.set_frame_and_progress(frame, process)

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
