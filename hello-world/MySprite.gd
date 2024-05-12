extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var mySprite = Sprite2D.new()
	
	# 设置图片
	var icon = preload("res://icon.svg")
	mySprite.set_texture(icon)
	
	# 修改名称
	mySprite.name = "mySprite"
	
	# 修改坐标
	mySprite.position.x = 200
	mySprite.position.y = 200
	
	# 将对象添加到当前场景中
	add_child(mySprite)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var sprite:Sprite2D = $mySprite
	sprite.rotate(0.1)
	pass
