extends Node2D

const dialog_lines: Array[String] = [
	"Phoenix:Hi!My name is Phoenix Wright, nice to meet you.",
	"Trucy:Hey there! I am Trucy.",
	"Phoenix:Hello, it's nice to meet you too.What are we learn today?",
	"Phoenix:Today we learning how to build a dialog sysytem.",
	"Phoenix:It might seem diffcult at first.",
	"Trucy:Awsome!"
]

var dialog_index: int = 0

@onready var character_sprite: Node2D = %CharacterSprite
@onready var dialog_ui: Control = %DialogUI
@onready var next_sentence_sound: AudioStreamPlayer = $NextSentenceSound

func _ready() -> void:
	dialog_ui.animation_done.connect(_on_text_animation_done)
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

func parse_line(line: String):
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}
	
func process_current_line():
	var line = dialog_lines[dialog_index]
	var line_info = parse_line(line)
	var character_name = Character.get_enum_from_string(line_info["speaker_name"])
	dialog_ui.change_line(character_name, line_info["dialog_line"])
	character_sprite.change_character(character_name)

func _on_text_animation_done():
	character_sprite.play_idle_animation()
