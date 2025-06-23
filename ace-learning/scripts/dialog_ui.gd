extends Control

signal animation_done
signal choice_selected

const ANIMATION_SPEED := 20
const NO_SOUND_CHARS := [".", ",", "!", "?"]
const ChoiceButtonSence = preload("res://scenes/choice_button.tscn")

var animate_text := true
var current_visible_characters := 0
var current_character_detail: Dictionary

@onready var speaker_name: Label = %SpeakerName
@onready var speaker_panel: Control = $SpeakerPanel
@onready var dialog_line: RichTextLabel = %DialogLine
@onready var text_blip_timer: Timer = $TextBlipTimer
@onready var sentence_pause_timer: Timer = $SentencePauseTimer
@onready var text_blip_sound: AudioStreamPlayer = $TextBlipSound
@onready var animated_line: AnimatedSprite2D = %AnimatedLine
@onready var choice_list: VBoxContainer = $ChoicesContainer/ChoiceList
@onready var evidence_center_container: CenterContainer = $EvidenceCenterContainer
@onready var court_data_button: Button = $ConfigPanel/HBoxContainer/CourtDataButton

func _ready() -> void:
	choice_list.hide()
	speaker_panel.visible = false
	animated_line.visible = false
	speaker_name.text = ""
	dialog_line.text = ""
	
func _process(delta: float) -> void:
	if animate_text and sentence_pause_timer.is_stopped():
		if dialog_line.visible_ratio < 1:
			dialog_line.visible_ratio += (1.0 / dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			if dialog_line.visible_characters > current_visible_characters:
				current_visible_characters = dialog_line.visible_characters
				var current_char = dialog_line.text[current_visible_characters -1]
				if current_visible_characters < dialog_line.text.length():
					var next_char = dialog_line.text[current_visible_characters]
					if NO_SOUND_CHARS.has(current_char) and next_char == " ":
						text_blip_timer.stop()
						sentence_pause_timer.start()
		else:
			animate_text = false
			text_blip_timer.stop()
			animation_done.emit()

func change_line(character_name: Character.Name, line: String):
	speaker_panel.visible = true
	if character_name == -1:
		speaker_panel.visible = false
	else:
		current_character_detail = Character.CHARACTER_DETAILS.get(character_name)
		speaker_name.text = current_character_detail["name"]
	current_visible_characters = 0
	dialog_line.text = line
	dialog_line.visible_characters = 0
	animate_text = true
	text_blip_timer.start()
	
func skip_text_animation():
	dialog_line.visible_ratio = 1

func display_choices(choices: Array):
	if not choices:
		return
	for child in choice_list.get_children():
		child.queue_free()
	for choice in choices:
		var choice_button = ChoiceButtonSence.instantiate()
		choice_button.pressed.connect(_on_choice_button_pressed.bind(choice["goto"]))
		choice_button.text = choice["text"]
		choice_list.add_child(choice_button)
	var empty_control = Control.new()
	empty_control.custom_minimum_size.y = 80
	choice_list.add_child(empty_control)
	choice_list.show()

func _on_text_blip_timer_timeout() -> void:
	text_blip_sound.play_sound(current_character_detail.get("gender", "default"))


func _on_sentence_pause_timer_timeout() -> void:
	text_blip_timer.start()

func _on_choice_button_pressed(anchor: String) -> void:
	choice_selected.emit(anchor)
	choice_list.hide()

func _on_court_data_button_pressed() -> void:
	evidence_center_container.show()
