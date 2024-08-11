extends PlayerBaseState

var variable_jump_height
@onready var jump_sfx = $JumpSFX

func enter():
	play("jump")
	jump()
	variable_jump_height  = false
	input.jump_buffer = false
	jump_sfx.play()

func physics_update(delta):
	move(delta, true)
	
	# variable_jump_height用于防止在相同条件下重复进入
	if not variable_jump_height and not input.jump_pressed:
		variable_jump_height = true
		if object.velocity.y <= 0:
			object.velocity.y /= 2
	
	if object.velocity.y >= 0:
		change_state("fall")
	
