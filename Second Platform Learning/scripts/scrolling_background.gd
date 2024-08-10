extends ParallaxLayer

@export var speed := 20

func _process(delta):
	motion_offset.x -= speed * delta
