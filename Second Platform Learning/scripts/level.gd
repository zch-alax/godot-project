extends Node2D

func pause():
	Game.main.pause_menu.show()
	get_tree().paused = true
	Game.main.pause_menu.enable()
	
func resume():
	Game.main.pause_menu.disable()
	get_tree().paused = false
	Game.main.pause_menu.hide()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pause()
