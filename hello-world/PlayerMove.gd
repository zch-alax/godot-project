extends CharacterBody2D

@export var speed = 400
var screen_size


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size # 获得屏幕大小
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity1 = Vector2.ZERO # 定义一个初始化速度，初始化速度为0
	if Input.is_action_pressed("move_right"):
		velocity1.x += 1
	if Input.is_action_pressed("move_left"):
		velocity1.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity1.y += 1
	if Input.is_action_pressed("move_up"):
		velocity1.y -= 1
	if velocity1.length() <= 0:
		return
		
	var info: KinematicCollision2D = move_and_collide(velocity1 * delta)
	if info != null:
		print(info.get_collider())
	#velocity1 = velocity1.normalized() * speed
	#position += velocity1 * delta
	#position.x = clamp(position.x, 0, screen_size.x)
	#position.y = clamp(position.y, 0, screen_size.y)			
	pass
