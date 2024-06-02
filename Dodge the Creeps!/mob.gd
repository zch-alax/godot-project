extends RigidBody2D

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# 从三个动画类型中随机选择一个播放
	var mob_types = animated_sprite.sprite_frames.get_animation_names()
	animated_sprite.play(mob_types[randi() % mob_types.size()])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
