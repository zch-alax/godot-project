extends State

func physics_update(delta):
	var x_input = Input.get_axis("btn_left", "btn_right")
	object.direction = x_input
	object.velocity.x = x_input * 90
	
	if Input.is_action_just_pressed("btn_jump") and object.is_on_floor():
		change_state("jump")
	elif not object.is_on_floor() and object.velocity.y >= 0:
		change_state("fall")
	elif x_input == 0 and object.is_on_floor():
		change_state("idle")
	elif object.is_on_floor():
		object.animated_sprite.play("run")
	
	object.move_and_slide()
