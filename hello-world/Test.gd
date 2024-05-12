extends Node


@export var a = 1
var b = true
var c = 0.5
var d = "just test"
var e = null
@export var f:NodePath
@export_file("*.txt") var h: String

# Called when the node enters the scene tree for the first time.
func _ready():
	print(a)
	print(b)
	print(c)
	print(d)
	print(e)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# 数组遍历方式
func arrayInterator():
	var arr = [1, 3, 4]
	
	# 遍历数组的方法1
	for i in range(10):
		print(i)
	
	# 遍历数组的方法2
	for param in arr:
		print(param)
		
	# 遍历数组的方法3
	for index in range(arr.size()):
		print(arr[index])
	pass
	
# 字典遍历方式
func dictionaryIterator():
	var arr = [1, 3, 4]
	var dict = {
		2: 3,
		"key": "字符串作为key",
		arr: "数组作为key"
	}
	# 字典遍历的方法1
	for key in dict:
		print("key:" + key as String)
		print("value:" + dict[key] as String)
	
	# 字典遍历方法2
	for key in dict.keys():
		print("key:" + key as String)
		print("value:" + dict[key] as String)
		
	# 字典遍历方法3
	for value in dict.values():
		print("value:" + value as String)
	
	pass
	
class Animal:
	extends Object # 如果不指定，默认继承Object
	const STATIC_FIELD = "静态变量"
	# 属性
	var height: int
	func _init():
		print("Animal类的构造方法")
	func move():
		print("自定义方法")
	static func staticFunc():
		print(STATIC_FIELD) 
