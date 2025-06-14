extends Node2D

var transition_effect: String = "fade"
var dialog_file := "res://resources/story/first_scene.json"
var dialog_lines: Array = []
var dialog_index: int = 0

@onready var background: TextureRect = %Background
@onready var character_sprite: Node2D = %CharacterSprite
@onready var dialog_ui: Control = %DialogUI
@onready var next_sentence_sound: AudioStreamPlayer = $NextSentenceSound

func _ready() -> void:
	dialog_ui.animation_done.connect(_on_text_animation_done)
	dialog_ui.choice_selected.connect(_on_choice_selected)
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)
	dialog_lines = load_dialog(dialog_file)
	dialog_index = 0
	SceneManager.transition_in()
	
func _input(event: InputEvent) -> void:
	var line = dialog_lines[dialog_index]
	var has_choices = line.has("choices")
	if event.is_action_pressed("next_line") and not has_choices:
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
	if dialog_index >= dialog_lines.size() or dialog_index < 0:
		printerr("Error:dialog index out of bounds: ", dialog_index)
		return
	var line = dialog_lines[dialog_index]
	
	if line.has("location"):
		var background_file = "res://assets/images/" + line["location"] + ".png"
		background.texture = load(background_file)
		dialog_index += 1
		process_current_line()
		return
	
	if line.has("goto"):
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
	
	if line.has("anchor"):
		dialog_index += 1
		process_current_line()
		return
		
	if line.has("show_character"):
		var character_name = Character.get_enum_from_string(line["show_character"])
		character_sprite.change_character(character_name, false, line.get("expression", ""))
	elif line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		character_sprite.change_character(character_name, true, line.get("expression", ""))
	
	if line.has("next_scene"):
		var next_scene = line["next_scene"]
		dialog_file = "res://resources/story/" + next_scene + ".json" if not next_scene.is_empty() else ""
		transition_effect = line.get("transition", "fade")
		SceneManager.transition_out(transition_effect)
		return
	
	if line.has("choices"):
		dialog_ui.display_choices(line["choices"])
	elif line.has("text"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		dialog_ui.change_line(character_name, line["text"])
	else:
		dialog_index += 1
		process_current_line()
		return

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
	
func _on_choice_selected(anchor: String):
	dialog_index = get_anchor_position(anchor)
	process_current_line()
	next_sentence_sound.play()

func _on_transition_out_completed():
	if !dialog_file.is_empty():
		dialog_lines = load_dialog(dialog_file)
		dialog_index = 0
		var first_line = dialog_lines[dialog_index]
		if first_line.has("location"):
			background.texture = load("res://assets/images/" + first_line["location"] + ".png")
		SceneManager.transition_in(transition_effect)
	else:
		print("End")
	
func _on_transition_in_completed():
	process_current_line()
