extends Area2D

@onready var pickup_sfx = $PickupSFX
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

func _on_player_entered(player):
	player.sword = true
	animated_sprite.visible = false
	pickup_sfx.play()
	collision_shape.set_deferred("disabled", true)


func _on_pickup_sfx_finished():
	queue_free()
