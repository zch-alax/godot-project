extends State
class_name PlayerBaseState

var input:
	get:
		return object.input

var is_on_floor:
	get:
		return object.is_on_floor()

func play(animation):
	if object.sword and object.animated_sprite.sprite_frames.has_animation(animation + "_sword"):
		animation += "_sword"
	object.animated_sprite.play(animation)

func move(delta, apply_g, update_direction = true, direction = input.x):
	accelerate(delta, direction)
	if apply_g:
		apply_gravity(delta)
	if update_direction:
		object.direction = direction
	object.move_and_slide()

func jump():
	object.velocity.y = -350
	object.velocity.x += input.x * Player.MAX_SPEED

func accelerate(delta, direction = input.x):
	var mult = Player.AIR_MULTIPLIER if not object.is_on_floor() else 1.0
	object.velocity.x = move_toward(object.velocity.x, Player.MAX_SPEED * direction, Player.ACCELERATION * mult * delta)

func apply_gravity(delta):
	var g = Player.JUMP_GRAVITY if fsm.current_state == "jump" else Player.FALL_GRAVITY
	object.velocity.y = move_toward(object.velocity.y, Player.TERMINAL_VELOCITY, g * delta)
