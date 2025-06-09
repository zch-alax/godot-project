extends Node2D

var dialog_lines: Array = []

var dialog_index: int = 0

@onready var character_sprite: Node2D = %CharacterSprite
@onready var dialog_ui: Control = %DialogUI
@onready var next_sentence_sound: AudioStreamPlayer = $NextSentenceSound

func _ready() -> void:
	dialog_ui.animation_done.connect(_on_text_animation_done)
	dialog_lines = load_dialog("res://resources/story/story.json")
	dialog_index = 0
	process_current_line()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_line"):
		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()
		else:
			if dialog_index < len(dialog_lines) -1:
				dialog_index += 1
				next_sentence_sound.play()
				process_current_line()

func get_anchor_position(anchor: String):
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return i
	printerr("Error:could not find anchor:" + anchor)
	return 0
	
func process_current_line():
	var line = dialog_lines[dialog_index]
	if line.has("goto"):
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
	
	if line.has("anchor"):
		dialog_index += 1
		process_current_line()
		return
	
	var character_name = Character.get_enum_from_string(line["speaker"])
	dialog_ui.change_line(character_name, line["text"])
	character_sprite.change_character(character_name)

func load_dialog(file_path):
	# check if the file exists
	if not FileAccess.file_exists(file_path):
		printerr("Error: File does not exists: " + file_path)
		return null
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("Error: Failed to open file:" + file_path)
		return null
	var content = file.get_as_text();
	var json_content = JSON.parse_string(content)
	if json_content == null:
		printerr("Error: Failed to parse JSON from file:" + file_path)
	return json_content

func _on_text_animation_done():
	character_sprite.play_idle_animation()
