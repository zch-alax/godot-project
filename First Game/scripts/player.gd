extends CharacterBody2D


const SPEED = 130.0 # 移动速度
const JUMP_VELOCITY = -300.0 # 跳跃速度

# 自定义重力变量，默认为980
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D


# physics_process 默认以固定速率每秒运行60次，有助于物理运行顺畅，我们用它来处理涉及物理引擎的任何事物
func _physics_process(delta):
	# 如果玩家没有站在地板上时施加重力
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# 如果玩家按下空格键且玩家在地板上时，施加跳跃速度
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 跳跃并按下方向键时施加方向并相应移动
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# 获取输入方向 -1(left) 0 1(right)
	var direction = Input.get_axis("move_left", "move_right")
	
	# 根据输入方向提供转向
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# 播放动画
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("iump")

	
	# 提供移动
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
