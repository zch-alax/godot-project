extends State
class_name PlayerBaseState

var is_gravity = false

func play(animation):
	object.animated_sprite.play(animation)

func move(delta, apply_g, update_direction = true, direction = object.get_input_x()):
	accelerate(delta, direction)
	if apply_g:
		apply_gravity(delta)
	if update_direction:
		object.direction = direction
	object.move_and_slide()

func jump():
	object.velocity.y = -300

func accelerate(delta, direction = object.get_input_x()):
	var mult = Player.AIR_MULTIPLIER if not object.is_on_floor() else 1.0
	object.velocity.x = move_toward(object.velocity.x, Player.MAX_SPEED * direction, Player.ACCELERATION * mult * delta)

func apply_gravity(delta):
	var g = Player.JUMP_GRAVITY if fsm.current_state == "jump" else Player.FALL_GRAVITY
	object.velocity.y = move_toward(object.velocity.y, Player.TERMINAL_VELOCITY, g * delta)
