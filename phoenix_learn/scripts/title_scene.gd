extends Node2D


@onready var new_game_button: Button = %NewGameButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)

func _on_new_game_button_pressed() -> void:
	SceneManager.transition_out()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_transition_out_completed() -> void:
	SceneManager.change_scene("res://scenes/main.tscn")
