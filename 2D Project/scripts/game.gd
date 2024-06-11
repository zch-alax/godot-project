extends Node2D

@onready var path_follow = %PathFollow2D
@onready var game_over = %GameOver

func _ready():
	$GameOver.hide()

func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_mob.global_position = path_follow.global_position
	add_child(new_mob)


func _on_timer_timeout():
	if get_tree().get_nodes_in_group("mobs").size() < 30:
		spawn_mob()


func _on_player_health_depleted():
	game_over.visible = true
	get_tree().paused = true


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
	

func _on_quit_button_pressed():
	get_tree().quit()
