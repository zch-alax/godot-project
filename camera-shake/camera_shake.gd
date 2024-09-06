extends Camera2D

# 用于生成伪随机数的类
var rng := RandomNumberGenerator.new()
var duration := 0.0
var force

func _process(delta: float) -> void:
	if duration > 0:
		var forceX = rng.randf_range(-1, 1) * force
		var forceY = rng.randf_range(-1, 1) * force
		
		offset = Vector2(forceX, forceY)
		duration -= delta
	else:
		offset = Vector2.ZERO
	
# shakeDuration 震动次数 shakeForce 震动幅度
func shake_camera(shakeDuration: float, shakeForce: float):
	duration = shakeDuration
	force = shakeForce


func _on_button_button_down() -> void:
	shake_camera(0.5, 15)
