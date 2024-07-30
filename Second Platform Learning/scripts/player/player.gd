extends CharacterBody2D


var direction:
	set(value):
		if value == 0 or value == direction: return
		direction = value
		animated_sprite.flip_h = value == -1

@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta):
	var x_input = Input.get_axis("btn_left", "btn_right")
	direction = x_input
	if Input.is_action_just_pressed("btn_jump") and is_on_floor():
		velocity.y = -300
		animated_sprite.play("jump")
	elif not is_on_floor() and velocity.y >= 0:
		animated_sprite.play("fall")
	elif x_input == 0 and is_on_floor():
		animated_sprite.play("idle")
	elif is_on_floor():
		animated_sprite.play("run")
	
	velocity.y += 900 * delta
	velocity.x = x_input * 90
	move_and_slide()
