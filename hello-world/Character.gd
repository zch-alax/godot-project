class_name Character

extends Node

@export var profession: String
@export var health: int

func died():
	health = 0
	print(profession + " YOU ARE DIED!")
	

# Equipment是Character的内部类
# 内部类有时比字典安全，因为如果我们尝试访问不存在的内容时，我们会在游戏开始前收到错误，这叫做类型安全

var chest := Equipment.new() # 胸甲
var legs := Equipment.new() # 腿甲

func _ready():
	chest.armor = 20
	print(legs.weight)

class Equipment:
	var armor := 10
	var weight := 5
