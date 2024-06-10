extends Area2D

const SPEED = 1000
const RANGE = 1200

var travelled_distance = 0

# 子弹飞行速度的代码
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta
	
	if travelled_distance > RANGE:
		queue_free()

# 当子弹碰撞到敌人时，发送产生伤害的信号
func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
