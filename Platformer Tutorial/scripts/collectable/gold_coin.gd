extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collect_fsx = $CollectFSX


func _ready():
	animated_sprite.play("idle")


func _on_body_entered(_body):
	animated_sprite.play("collect")
	collect_fsx.play()

func _on_animated_sprite_animation_finished():
	queue_free()
