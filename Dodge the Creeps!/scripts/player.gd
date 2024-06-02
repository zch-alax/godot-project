extends Area2D

@export var speed = 400
@onready var animated_sprite = $AnimatedSprite2D

var screen_size

signal hit


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size # 获得游戏窗口大小
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		
	if velocity.length() > 0:
		# normalized()将速度的长度归一化，也就是将速度的长度设置为 1，然后乘以想要的速度
		velocity = velocity.normalized() * speed
		animated_sprite.play()
	else:
		animated_sprite.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		animated_sprite.animation = "walk"
		animated_sprite.flip_v = false
		animated_sprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		animated_sprite.animation = "up"
		animated_sprite.flip_h = false
		animated_sprite.flip_v = velocity.y < 0

# 敌人每次击中玩家时都会发出一个信号。我们需要禁用玩家的碰撞检测，确保我们不会多次触发 hit 信号
func _on_body_entered(body):
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
