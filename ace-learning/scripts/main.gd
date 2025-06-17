extends Node2D

@export_category("dialogue")
@export_file("*.json") var dialog_file

var dialog_lines: Array = []
var dialog_index: int = 0

func _ready() -> void:
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)
	dialog_lines = load_dialog(dialog_file)
	dialog_index = 0
	SceneManager.transition_in()

func process__current_line():
	if dialog_index >= dialog_lines.size() or dialog_index < 0:
		printerr("ERROR:dialog index out of bounds: ", dialog_index)
	
	var line = dialog_lines[dialog_index]
	
	if line.has("text"):
		pass

func load_dialog(file_path: String):
	if not FileAccess.file_exists(file_path):
		printerr("Error:File does not exists: " + file_path)
		return null
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("ERROR:File does not open: " + file_path)
		return null
	var content = JSON.parse_string(file.get_as_text())
	if content == null:
		print("ERROR: Failed to parse JSON from file:" + file_path)
	return content

func _on_transition_out_completed():
	pass

func _on_transition_in_completed():
	process__current_line()
