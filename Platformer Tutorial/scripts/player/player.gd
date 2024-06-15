extends CharacterBody2D

@export var speed := 90

var direction:
	get: return direction
	set(value):
		if value == 0 or value == direction:
			return value
		animated_sprite.flip_h = value == -1

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	var x_input = Input.get_axis("move_left", "move_right")
	direction = x_input
	velocity.x = x_input * speed
	velocity.y += 980 * delta
	
	if is_on_floor():
		if x_input == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
			
		if Input.is_action_just_pressed("jump"):
			velocity.y = -300
			animated_sprite.play("jump")
	else:
		if velocity.y >= 0:
			animated_sprite.play("fall")
	
	
	move_and_slide()
