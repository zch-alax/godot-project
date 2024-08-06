extends PlayerBaseState

@onready var coyote_timer = $CoyoteTimer

func enter():
	play("fall")
	if fsm.previous_state != "jump":
		coyote_timer.start()

func physics_update(delta):
	move(delta, true)
	
	if not coyote_timer.is_stopped() and input.jump_just_pressed:
		change_state("jump")
	
	if is_on_floor:
		if input.x == 0:
			change_state("idle")
		else:
			change_state("run")
