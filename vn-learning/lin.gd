@tool
extends DialogicPortrait

@export var a := 0

func _update_portrait(passed_character: DialogicCharacter, passed_portrait: String) -> void:
	if passed_portrait == "":
		passed_portrait = passed_character['default_portrait']
	
	if $AnimatedSprite2D.sprite_frames.has_animation(passed_portrait):
		$AnimatedSprite2D.play(passed_portrait)

func _get_covered_rect() -> Rect2:
	return Rect2($AnimatedSprite2D.position, $AnimatedSprite2D.sprite_frames.get_frame_texture($AnimatedSprite2D.animation, 0).get_size()*$AnimatedSprite2D.scale)
