extends Control

@export_group("UI")
@export var character_name_text: Label
@export var text_box: Label
@export var left_avatar: TextureRect
@export var right_avatar: TextureRect

@export_group("Dialogue")
@export var main_dialogue: DialogueGroup

var dialogue_index := 0
var typing_tween: Tween

func _ready():
	display_next_dialogue()


func display_next_dialogue():
	if dialogue_index >= len(main_dialogue.dialogue_list):
		visible = false
		return
	
	var dialogue = main_dialogue.dialogue_list[dialogue_index]
	
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		text_box.text = dialogue.content
		dialogue_index += 1
	else:
		character_name_text.text = dialogue.character_name
		
		typing_tween = get_tree().create_tween()
		
		text_box.text = ""
		
		for chr in dialogue.content:
			typing_tween.tween_callback(append_character.bind(chr)).set_delay(0.05)
		
		typing_tween.tween_callback(func(): dialogue_index += 1)
		
		if dialogue.show_on_left: 
			left_avatar.texture = dialogue.avatar
			right_avatar.texture = null
		else:
			right_avatar.texture = dialogue.avatar
			left_avatar.texture = null

func append_character(chr: String):
	text_box.text += chr

func _on_click(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		display_next_dialogue()
