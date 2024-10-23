extends CanvasLayer

@export var player_name: LineEdit
@export var player_color: ColorPickerButton

var config_file = ConfigFile.new()
var key = "sdfer213"

func _on_save_button_pressed() -> void:
	config_file.set_value("Settings", "PlayerName", player_name.text)
	config_file.set_value("Settings", "PlayerColor", player_color.color)
	
	config_file.save_encrypted_pass("user://settings.cfg", key)


func _on_load_button_pressed() -> void:
	var result = config_file.load_encrypted_pass("user://settings.cfg", key)
	if result == OK:
		player_name.text = config_file.get_value("Settings", "PlayerName")
		player_color.color = config_file.get_value("Settings", "PlayerColor")
