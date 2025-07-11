extends Control

signal animation_done
signal choice_selected

const ChoiceButtonSence = preload("res://scenes/player_choice.tscn")
const ANIMATION_SPEED := 20
const NO_SOUND_CHARS := [".", ",", "!", "?"]

var animate_text := true
var current_visible_characters := 0
var current_character_details: Dictionary

@onready var choice_list: VBoxContainer = %ChoiceList
@onready var dialog_line: RichTextLabel = %DialogLine
@onready var speaker_name: Label = %SpeakerName
@onready var text_blip_sound: AudioStreamPlayer = $TextBlipSound
@onready var text_blip_timer: Timer = $TextBlipTimer
@onready var sentence_pause_timer: Timer = $SentencePauseTimer

func _ready() -> void:
	choice_list.hide()
	dialog_line.text = ""
	speaker_name.text = ""

func _process(delta: float) -> void:
	if animate_text and sentence_pause_timer.is_stopped():
		if dialog_line.visible_ratio < 1:
			dialog_line.visible_ratio += (1.0/dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			if dialog_line.visible_characters > current_visible_characters:
				current_visible_characters = dialog_line.visible_characters
				var current_char = dialog_line.text[current_visible_characters - 1]
				if current_visible_characters < dialog_line.text.length():
					var next_char = dialog_line.text[current_visible_characters]
					if NO_SOUND_CHARS.has(current_char) and next_char == " ":
						text_blip_timer.stop()
						sentence_pause_timer.start()
		else:
			animate_text = false
			text_blip_timer.stop()
			animation_done.emit()

func display_choices(choices: Array):
	for child in choice_list.get_children():
		child.queue_free()
	# create a new button for each choice
	for choice in choices:
		var choice_button = ChoiceButtonSence.instantiate()
		choice_button.pressed.connect(_on_choice_button_pressed.bind(choice["goto"]))
		choice_button.text = choice["text"]
		choice_list.add_child(choice_button)
	
	choice_list.show()
	

func change_line(character_name: Character.Name, line: String):
	current_character_details = Character.CHARACTER_DETAILS[character_name]
	speaker_name.text = current_character_details["name"]
	current_visible_characters = 0
	dialog_line.text = line
	dialog_line.visible_characters = 0
	animate_text = true
	text_blip_timer.start()
	
func skip_text_animation():
	dialog_line.visible_ratio = 1


func _on_text_blip_timer_timeout() -> void:
	text_blip_sound.play_sound(current_character_details)


func _on_sentence_pause_timer_timeout() -> void:
	text_blip_timer.start()

func _on_choice_button_pressed(anchor: String) -> void:
	choice_selected.emit(anchor)
	choice_list.hide()
