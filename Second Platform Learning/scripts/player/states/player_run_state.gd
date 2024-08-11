extends PlayerBaseState

@onready var sfx = $FootstepsSFX
@onready var timer = $FootstepsTimer

func enter():
	play("run")
	sfx.play()
	timer.start()

func physics_update(delta):
	move(delta, false)
	
	if input.jump_just_pressed:
		change_state("jump")
	elif not is_on_floor:
		change_state("fall")
	elif input.x == 0:
		change_state("idle")

func exit():
	timer.stop()

func _on_footsteps_timer_timeout():
	sfx.play()
