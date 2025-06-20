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

@onready var character_sprite: Node2D = $CanvasLayer2/Control/CharacterSprite
@onready var back_ground: TextureRect = %BackGround
@onready var dialog_ui: Control = $CanvasLayer2/dialog_ui

func _ready() -> void:
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)
	dialog_ui.animation_done.connect(_on_animation_done)
	dialog_lines = load_dialog(dialog_file)
	dialog_index = 0
	SceneManager.transition_in()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_line"):
		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()
		else:
			if dialog_index < dialog_lines.size() -1:
				dialog_index += 1
				process__current_line()

func process__current_line():
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
	
	if line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		character_sprite.change_character(character_name, true, line.get("expression", ""))
	
	if line.has("text"):
		var character_name = Character.get_enum_from_string(line.get("speaker", ""))
		dialog_ui.change_line(character_name, line["text"])
			

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

func _on_animation_done():
	character_sprite.play_idle_animation()
	dialog_ui.animated_line.visible = true

func _on_transition_out_completed():
	pass

func _on_transition_in_completed():
	process__current_line()
