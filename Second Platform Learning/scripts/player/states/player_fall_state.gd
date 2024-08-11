extends PlayerBaseState

var first_time = false

@onready var coyote_timer = $CoyoteTimer
@onready var sfx = $LandingSFX

func enter():
	play("fall")
	if fsm.previous_state != "jump":
		coyote_timer.start()

func physics_update(delta):
	move(delta, true)
	
	if not coyote_timer.is_stopped() and input.jump_just_pressed:
		change_state("jump")
	elif is_on_floor:
		if input.jump_buffer:
			change_state("jump")
		else:
			change_state("idle" if input.x == 0 else "run")
			if first_time: 
				sfx.play()
			first_time = true
