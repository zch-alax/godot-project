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
#@export var a = 10
## const为设置常量
#const GRAVITY = -9.81
#
#func _ready():
	#var age = 42
	#var text = "age: " + str(age)
	#print(text)
	#
	#var pi = 3.14
	#print(int(pi)) # 非四舍五入，而是只取整数部分
	#
	## 常用的数据结构：Vector2 Vector3
	#var position2D = Vector2(1.0, 3.0)
	#position2D.y += 3
	#var position3D = Vector3(5.0, 1.0, 2.0)
	#position3D.z -= 5
	#print(position2D)
	#print(position3D)
	#
	## 指定变量类型的两种方法
	## 第一种方法是我们自己指定
	## 第二种方法是Godot识别到后面的值后自动指定
	#var damage: int = 15
	#var number := 33
	#print(a)

# 4. 函数
#func _ready():
	#var result = add(1, 2)
	#print(result)
	#var items: Array[String] = ["Potion", "Feather"]
	#print(items[0])
	## 修改元素
	#items[1] = "Staff"
	## 移除元素
	#items.remove_at(1)
	## 添加元素
	#items.append("Sword")
#
#func add(num1: int, num2: int) -> int:
	#var result = num1 + num2
	#return result
#
#func _input(event):
	#if event.is_action_pressed("my_action"):
		#jump()
#
## 需要一个事件来触发跳跃，比如按下空格
#func jump():
	## 添加一个向上的力
	## 添加跳跃的音效
	## 添加跳跃的动画
	#print("JUMP")
	#
#func get_rand():
	#randf() # 返回一个0-1之间的随机数
	#var a = randi_range(10, 100) # 返回一个指定最小值-最大值之间的随机整数
	#randf_range(11.1, 23.5) # 返回一个指定最小值-最大值的随机小数

# 5. 枚举
# 可以通过赋值来调整元素
#enum Alignment {ALLY, NEUTRAL, ENEMY} # 不赋值，默认为0，1，2
#enum Alignment {ALLY = 1, NEUTRAL = 0, ENEMY = -1}
## var unit_alignment = Alignment.ALLY
## 导出到检视器上，可以在检视器上选择对应的元素
#@export var unit_alignment: Alignment
#
#func _ready():
	#if unit_alignment == Alignment.ENEMY:
		#print("You are not welcome here.")
	#else:
		#print("Welcome!")
	#
	## 相当于swith	
	#match unit_alignment:
		#Alignment.ALLY:
			#print("Hello!Friend!")
		#Alignment.NEUTRAL:
			#print("Hello!")
		#Alignment.ENEMY:
			#print("KILL YOU!")
		#_:
			#print("WHO ARE YOU?")

# 6. 信号
#signal leveled_up(msg)
#
#var xp := 0
#
#func _ready():
	#leveled_up.connect(_on_leveled_up)
	#
#func _on_timer_timeout():
	#xp += 5
	#print(xp)
	#if xp == 20:
		#leveled_up.emit("LEVEL UP!!!")
		#xp = 0
	#
#func _on_leveled_up(msg):
	#print(msg)


# 7. setter
#signal health_changed(new_health)
#
#var health := 100:
	#set(value):
		#health = clamp(value, 0, 100) # 设置最大最小值 小于0则赋值0 大于100则赋值100
		#health_changed.emit(health)
		#
#func _ready():
	#health_changed.connect(_on_health_changed)
	#health = -150
	#
#func _on_health_changed(new_health):
	#print(new_health)
	

# 8. getter
#var chance := 0.2
#var chance_pct: int:
	#get:
		#return chance * 100
	#set(value):
		#chance = float(value) / 100
		#
#
#func _ready():
	#print(chance_pct) # 20
	#chance_pct = 40
	#print(chance_pct) # 40
	#chance = 0.6
	#print(chance_pct) # 60

# 9. classes
@export var character_kill: Character

func _ready():
	character_kill.died()
