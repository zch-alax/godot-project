extends Node2D

@onready var path_follow = %PathFollow2D
@onready var game_over = %GameOver

func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_mob.global_position = path_follow.global_position
	add_child(new_mob)


func _on_timer_timeout():
	spawn_mob()


func _on_player_health_depleted():
	game_over.visible = true
	get_tree().paused = true
