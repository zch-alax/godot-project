class_name Character
extends Node

enum Name {
	PHOENIX
}

const CHARACTER_DETAILS := {
	Name.PHOENIX: {
		"name": "成步堂",
		"gender": "male",
		"sprite_frames": ""
	}
}

static func get_enum_from_string(string_value: String):
	var upper_str = string_value.to_upper()
	if Name.has(upper_str):
		return Name[upper_str]
	else:
		push_error("Invalid Character name:" + string_value)
		return -1
