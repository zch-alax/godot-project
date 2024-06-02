extends CharacterBody2D

@export var speed = 300 # 移动速度


# 八向移动
# 通过w/A/S/D或上/下/左/右进行移动，且游戏角色可通过通过按下两个方向键来实现斜向移动

#func get_input():
	## 我们使用 Input 的 get_vector() 来检查四个按键事件，并返回一个方向向量的累加值。
	#var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	##print(input_direction) 
	## left(-1,0) right(1,0) up(0,-1) down(0,1) right-down(0.707107, 0.707107) left-up(-0.707107, -0.707107) √2/2
	#velocity = input_direction * speed
	## 我们可以将长度为 1 的方向矢量乘以所需的速度来设定速度。
#func _physics_process(delta):
	#get_input()
	#move_and_slide() # 提供了一种快捷方法来实现滑动且无需编写太多代码.


# Asteroids式运动（旋转+移动）
#@export var rotation_speed = 1.5 # 旋转速度
#
#var rotation_direction = 0
#func get_input():
	#rotation_direction = Input.get_axis("ui_left", "ui_right")
	#velocity = transform.x * Input.get_axis("move_up", "move_down") * speed
	## 要设置速度，我们使用物体的 transform.x ，这是一个指向物体 “前进” 方向的矢量，然后乘以速度。
	#
#func _physics_process(delta):
	#get_input()
	#rotation += rotation_direction * rotation_speed * delta
	#move_and_slide()

# 旋转+移动（鼠标）
#func get_input():
	#look_at(get_global_mouse_position())
	## Node2D中的look_at()方法，使玩家朝向鼠标的位置。
	#velocity = transform.x * Input.get_axis("move_up", "move_down") * speed
	#
	#
#func _physics_process(delta):
	#get_input()
	#move_and_slide()

# 点击并移动
var target = position

func _input(event):
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()
		
func _physics_process(delta):
	velocity = position.direction_to(target) * speed
	# look_at(target) # 取消注释的 rotation 代码可以使物体转向其运动方向
	# 注意我们在移动之前做的 distance_to() 检查. 如果没有这个检查, 物体在到达目标位置时会 "抖动", 因为它稍微移过该位置时就会试图向后移动, 只是每次移动步长都会有点远从而导致来回重复移动.
	if position.distance_to(target) > 10:
		move_and_slide()
