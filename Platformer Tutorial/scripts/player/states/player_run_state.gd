extends PlayerBaseState

@onready var footsteps_sfx = $FootstepsSFX
@onready var footsteps_timer = $FootstepsTimer


func enter():
	play("run")
	footsteps_sfx.play()
	
func physics_update(delta):
	move(delta, false)

	if input.jump_just_pressed:
		change_state("jump")
	elif not object.is_on_floor():
		change_state("fall")
	elif input.x == 0:
		change_state("idle")

func exit():
	footsteps_sfx.stop()

func _on_footsteps_timer_timeout():
	footsteps_sfx.play()
