extends State


func enter_condition():
	return Input.is_action_pressed("move_up")

func on_enter():
	animated_sprite.play("yellow")
	print("Entered yellowState")

func on_exit():
	print("Exited yellowState")
