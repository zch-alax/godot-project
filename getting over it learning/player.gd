class_name Player

extends CharacterBody2D

var mouse_pos = Vector2.ZERO
var look_dir = 0
# 默认重力 980
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	mouse_pos = get_global_mouse_position() # 获得全局的鼠标坐标
	# normalized() 归一化 将向量大小归一化为1
	var player_pos = global_position
	var pos = mouse_pos - player_pos
	look_dir = pos.normalized().angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, look_dir, 1.0) # 让角色旋转，能转起镐子
	
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
