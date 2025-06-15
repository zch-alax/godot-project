extends Node2D

@onready var title_h_box: HBoxContainer = %TitleHBox

func _ready() -> void:
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)

func change_scene(path: String):
	pass

func _on_new_game_button_pressed() -> void:
	SceneManager.transition_out()

func _on_continue_button_pressed() -> void:
	print("continue")

func _on_config_button_pressed() -> void:
	print("config")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_transition_out_completed() -> void:
	pass
	
func _on_transition_in_completed() -> void:
	pass
