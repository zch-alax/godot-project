extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var sword_sfx = $SwordSFX

func _ready():
	animated_sprite.play("idle")

func _on_player_entered(player):
	player.sword = true
	sword_sfx.play()
	animated_sprite.hide()
	$CollisionShape2D.set_deferred("disabled", true)

func _on_pickup_sfx_finished():
	queue_free()
