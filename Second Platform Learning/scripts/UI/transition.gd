extends CanvasLayer

signal faded_in
signal faded_out

@onready var animation_player = $ColorRect/AnimationPlayer

func fade_in():
	animation_player.play("fade_in")

func fade_out():
	animation_player.play("fade_out")
	


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			faded_in.emit()
		"fade_out":
			faded_out.emit()
