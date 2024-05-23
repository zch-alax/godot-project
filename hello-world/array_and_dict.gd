extends Node



func _ready():
	# 创建一个数组
	var arr = [10, "hello", 20.3]
	
	# 创建一个字典
	var d = {"name": "alan", "age": "22"}
	
	# 创建字典的另一种方式
	var e = {
		name = "alax",
		age = 23
	}
	# 添加一个键
	d["mother"] = "Masa"
	# 修改一个键
	d["age"] = 11
	# 移除一个键
	d.erase("mother")
	# 获取键的另一种方式
	e.age = 44
	
