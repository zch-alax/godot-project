class_name PlayerBaseState

extends State

var input:
	get:
		return object.input

func play(animation):
	if object.sword and object.animated_sprite.sprite_frames.has_animation(animation + "_sword"):
		animation += "_sword"
	object.animated_sprite.play(animation)

func accelerate(delta, direction = input.x):
	var mult = Player.AIR_MULTPLER if not object.is_on_floor() else 1.0
	object.velocity.x = move_toward(object.velocity.x, Player.MAX_SPEED * direction, Player.ACCELERATION * mult * delta)

func apply_gravity(delta):
	var g = Player.JUMP_GRAVITY if fsm.current_state == "jump" else Player.FALL_GRAVITY
	object.velocity.y = move_toward(object.velocity.y, Player.TERMINAL_VELOCITY, g * delta)

func move(delta, app_g, update_direction = true, direction = input.x):
	accelerate(delta, direction)
	if app_g:
		apply_gravity(delta)
	if update_direction:
		object.direction = direction
	
	object.move_and_slide()
