extends CharacterBody2D
class_name Player

const AIR_MULTIPLIER := 0.7
const MAX_SPEED := 90.0
const ACCELERATION := 900.0

const JUMP_GRAVITY := 900.0
const FALL_GRAVITY := 500.0
const TERMINAL_VELOCITY := 180.0

var sword = false:
	set(value):
		if sword == value: return
		sword = value
		var current_anim = animated_sprite.animation
		var target_anim = current_anim
		if value:
			target_anim += "_sword"
		else:
			target_anim = target_anim.replace("_sword", "")
		
		if animated_sprite.sprite_frames.has_animation(target_anim):
			var progress = animated_sprite.frame_progress
			var frame = animated_sprite.frame
			animated_sprite.play(target_anim)
			animated_sprite.set_frame_and_progress(frame, progress)

var direction:
	set(value):
		if value == 0 or value == direction: return
		direction = value
		animated_sprite.flip_h = value == -1

@onready var animated_sprite = $AnimatedSprite2D
@onready var fsm = $FSM
@onready var input = $InputHandler

func _ready():
	fsm.change_state("idle")

func _physics_process(delta):
	input.update()
	fsm.physics_update(delta)
