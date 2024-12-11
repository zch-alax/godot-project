extends CanvasLayer

func _on_start_button_pressed() -> void:
	Main.game.chapters.load_chapter("Chapter_1")
	self.hide()
	self.set_process_input(false)
	
	
func _on_chapter_select_button_pressed() -> void:
	pass # Replace with function body.

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
