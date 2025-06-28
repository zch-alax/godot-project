extends Node2D

const background_imgs := {
	"black": preload("res://assets/images/background/black.png"),
	"female_die": preload("res://assets/images/background/GyakutenSaiban010.png"),
	"follow": preload("res://assets/images/background/GyakutenSaiban042.png"),
	"court-outside": preload("res://assets/images/location/court-outside.png"),
	"judge-side": preload("res://assets/images/location/bg1005.png"),
	"prosecution-side": preload("res://assets/images/location/prosecution-side.png"),
	"defense-side": preload("res://assets/images/location/defense-side.png")
}

@export_category("dialogue")
@export_file("*.json") var dialog_file

var dialog_lines: Array = []
var dialog_index: int = 0
var wait_msg_gobal: String
var error_present: String

@onready var next_sentence_sound: AudioStreamPlayer = $NextSentenceSound
@onready var character_sprite: Node2D = $CanvasLayer2/Control/CharacterSprite
@onready var back_ground: TextureRect = %BackGround
@onready var dialog_ui: Control = $CanvasLayer2/dialog_ui

func _ready() -> void:
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)
	dialog_ui.animation_done.connect(_on_animation_done)
	dialog_ui.choice_selected.connect(_on_choice_selected)
	dialog_ui.evidence_center_container.config_panel.court_data_button.pressed.connect(_on_court_data_button_pressed)
	dialog_lines = load_dialog(dialog_file)
	dialog_index = 0
	SceneManager.transition_in()

func _input(event: InputEvent) -> void:
	var has_choice = dialog_lines[dialog_index].has("choices")
	var is_hovered = dialog_ui.court_data_button.is_hovered()
	var is_visiable = dialog_ui.evidence_center_container.is_visible_in_tree()
	if event.is_action_pressed("next_line") and not has_choice and not is_hovered and not is_visiable:
		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()
		else:
			if dialog_index < dialog_lines.size() -1:
				dialog_index += 1
				next_sentence_sound.play()
				process__current_line()
				
	if event.is_action_pressed("wait"):
		var line = dialog_lines[dialog_index]
		if line.has("wait"):
			wait_msg_gobal = line["wait"]
			dialog_index += 1
			process__current_line()

func process__current_line():
	dialog_ui.evidence_rect.hide()
	dialog_ui.animated_line.visible = false
	if dialog_index >= dialog_lines.size() or dialog_index < 0:
		printerr("ERROR:dialog index out of bounds: ", dialog_index)
	
	var line = dialog_lines[dialog_index]
	
	if line.has("background"):
		var background_img_name = line.get("background")
		SceneManager.transition_out()
		back_ground.texture = background_imgs.get(background_img_name)
		SceneManager.transition_in()
		dialog_index += 1
		return
	
	if line.has("goto"):
		dialog_index = get_anchor_position(line["goto"])
		process__current_line()
		return
	
	if line.has("anchor"):
		if line.has("error-present"):
			error_present = line["error-present"]
			dialog_ui.progress_bar.show()
		dialog_index += 1
		process__current_line()
		return
	
	if line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		character_sprite.change_character(character_name, true, line.get("expression", ""))
		if line.has("show_evidence"):
			dialog_ui.show_evidence(line["show_evidence"])
		
	if line.has("choices"):
		dialog_ui.display_choices(line["choices"])
	elif line.has("text"):
		if !line.has("action"):
			var character_name = Character.get_enum_from_string(line.get("speaker", ""))
			dialog_ui.change_line(character_name, line["text"])
		else:
			if line["action"] == wait_msg_gobal:
				var character_name = Character.get_enum_from_string(line.get("speaker", ""))
				dialog_ui.change_line(character_name, line["text"])
			else:
				dialog_index += 1
				process__current_line()
				return
		if line.has("add-evidence"):
			dialog_ui.add_evidence(line["add-evidence"])
	else:
		dialog_index += 1
		process__current_line()
		return

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

func get_anchor_position(anchor: String):
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return i
	printerr("Error:could not find anchor:" + anchor)
	return 0

func _on_animation_done():
	character_sprite.play_idle_animation()
	dialog_ui.animated_line.visible = true

func _on_transition_out_completed():
	pass

func _on_transition_in_completed():
	process__current_line()

func _on_choice_selected(anchor: String):
	dialog_index = get_anchor_position(anchor)
	process__current_line()
	next_sentence_sound.play()

func _on_court_data_button_pressed():
	# 获取到选择的证物
	var evidence_name = dialog_ui.evidence_center_container.get_selected_evidence_name()
	# 与对应的对话进行对比，如果有true-evidence的话，则进行下一步剧情
	var line = dialog_lines[dialog_index]
	if line.has("true-evidence") and line["true-evidence"] == evidence_name:
		dialog_index = get_anchor_position(line["true-goto"])
	else:
		# 如果出示的证物错误或者没选对对话，则出示错误对话
		var rand_num = str(randi_range(1, 2))
		dialog_index = get_anchor_position(error_present + rand_num)
	dialog_ui.progress_bar.value -= 2
	dialog_ui.evidence_center_container.hide()
	process__current_line()
	
