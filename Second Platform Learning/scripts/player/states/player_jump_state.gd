extends PlayerBaseState

func enter():
	play("jump")
	jump()

func physics_update(delta):
	move(delta, true)
	
	if object.velocity.y >= 0:
		change_state("fall")
	
