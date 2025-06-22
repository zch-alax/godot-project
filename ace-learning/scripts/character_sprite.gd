extends Node2D

var need_change: bool =false
var animated_sprite: AnimatedSprite2D
var pre_animated_sprite: AnimatedSprite2D

func _ready() -> void:
	SceneManager.transition_out_started.connect(_on_transition_out_started)
	self.modulate.a = 0

func change_character(character_name: Character.Name, is_talking: bool, expression: String):
	if pre_animated_sprite:
		pre_animated_sprite.visible = false
	need_change = true
	var en_name = Character.CHARACTER_DETAILS[character_name]["en_name"]
	if has_node(en_name):
		animated_sprite = get_node(en_name)
	else:
		return
	animated_sprite.visible = true
	pre_animated_sprite = animated_sprite
	if character_name == -1:
		return
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
	if character_name and self.modulate.a == 0:
		create_tween().tween_property(self, "modulate:a", 1.0, 0.2)

func play_idle_animation():
	if animated_sprite == null:
		return
	var last_animation = animated_sprite.animation
	if last_animation and not last_animation.ends_with("idle"):
		var idle_animation = last_animation.replace("talking", "idle")
		if animated_sprite.sprite_frames.has_animation(idle_animation):
			animated_sprite.play(idle_animation)
		else:
			animated_sprite.play("idle")

func _on_transition_out_started():
	if need_change and pre_animated_sprite != null:
		pre_animated_sprite.visible = false
	need_change = false
	
