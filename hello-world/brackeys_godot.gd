extends Node2D

# 1. 使用标签节点里面的属性，改变文本与字体颜色
#func _ready():
	#print("Hello, World!")
	#$Label.text = "hello"
	#$Label.modulate = Color.BLACK
	#
#func _input(event):
	#if event.is_action_pressed("my_action"):
		#$Label.modulate = Color.DARK_RED
	#if event.is_action_released("my_action"):
		#$Label.modulate = Color.BLACK

# 2. 变量的使用
#var health = 100
#
#func _input(event):
	#if event.is_action_pressed("my_action"):
		#health -= 20
		#
		#if health <= 0:
			#health = 0
			#print("YOU DIED!")
		#elif health < 50:
			#print("YOU ARE DANGER!")
		#else:
			#print("YOU ARE HEALTH!")


# 3. 基本类型与类型转化
# @export表示能将变量在inspector设置，脚本里面设置的是默认值，最终值以inspector里设置的为准
@export var a = 10
# const为设置常量
const GRAVITY = -9.81

func _ready():
	var age = 42
	var text = "age: " + str(age)
	print(text)
	
	var pi = 3.14
	print(int(pi)) # 非四舍五入，而是只取整数部分
	
	# 常用的数据结构：Vector2 Vector3
	var position2D = Vector2(1.0, 3.0)
	position2D.y += 3
	var position3D = Vector3(5.0, 1.0, 2.0)
	position3D.z -= 5
	print(position2D)
	print(position3D)
	
	# 指定变量类型的两种方法
	# 第一种方法是我们自己指定
	# 第二种方法是Godot识别到后面的值后自动指定
	var damage: int = 15
	var number := 33
	print(a)
