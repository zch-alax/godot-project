extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	self.modulate.a = 0
	pass

func change_character(character_name: Character.Name, is_talking: bool, expression: String):
	var sprite_frames = Character.CHARACTER_DETAILS[character_name]["sprite_frames"]
	var stance = "talking" if is_talking else "idle"
	var animation_name = expression + "-" + stance if expression else stance
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
		if animated_sprite.sprite_frames.has_animation(animation_name):
			animated_sprite.play(animation_name)
		else:
			animated_sprite.play(stance)
	else:
		play_idle_animation()
	if self.modulate.a == 0:
		create_tween().tween_property(self, "modulate:a", 1.0, 0.2)

func play_idle_animation():
	var last_animation = animated_sprite.animation
	if last_animation and not last_animation.ends_with("idle"):
		var idle_animation = last_animation.replace("talking", "idle")
		if animated_sprite.sprite_frames.has_animation(idle_animation):
			animated_sprite.play(idle_animation)
		else:
			animated_sprite.play("idle")
