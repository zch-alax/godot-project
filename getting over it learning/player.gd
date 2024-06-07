extends CharacterBody2D


@onready var player = self

var mouse_pos = Vector2.ZERO
var look_dir = 0

var gravity = 100
var velocity1 = Vector2.ZERO

func _physics_process(delta):
	mouse_pos = get_global_mouse_position()
	look_dir = (mouse_pos - player.global_position).normalized().angle() + deg_to_rad(90)
	player.rotation = lerp_angle(player.rotation, look_dir, 1.0)

	velocity1.y += gravity * delta
	set_velocity(velocity1)
	move_and_slide()
