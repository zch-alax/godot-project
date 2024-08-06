extends Node

var x = 0
var jump_pressed = false
var jump_just_pressed = false:
	set(value):
		jump_just_pressed = value
		if value:
			jump_buffer = true

var jump_buffer:
	get:
		return not jmp_buffer_timer.is_stopped()
	set(value):
		if value:
			jmp_buffer_timer.start()
		else:
			jmp_buffer_timer.stop()

@onready var jmp_buffer_timer = $JmpBufferTimer

func update():
	x = Input.get_axis("btn_left", "btn_right")
	jump_just_pressed = Input.is_action_just_pressed("btn_jump")
	jump_pressed = Input.is_action_pressed("btn_jump")
