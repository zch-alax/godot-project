class_name Character
extends Node

enum Name {
	PHOENIX,
	MIA,
	NONAME,
	LARRY,
	JUDGE,
	WINSTON
}

const CHARACTER_DETAILS := {
	Name.PHOENIX: {
		"en_name": "Phoenix",
		"name": "成步堂",
		"gender": "male",
		"sprite_frames": ""
	},
	Name.MIA: {
		"en_name": "Mia",
		"name": "千寻",
		"gender": "female",
		"sprite_frames": ""
	},
	Name.NONAME: {
		"en_name": "NoName",
		"name": " ???",
		"gender": "male",
		"sprite_frames": ""
	},
	Name.LARRY: {
		"en_name": "Larry",
		"name": "矢张",
		"gender": "male",
		"sprite_frames": ""
	},
	Name.JUDGE: {
		"en_name": "Judge",
		"name": "审判长",
		"gender": "male",
		"sprite_frames": preload("res://resources/character/judge.tres")
	},
	Name.WINSTON: {
		"en_name": "Winston",
		"name": "亚内",
		"gender": "male",
		"sprite_frames": preload("res://resources/character/winston.tres")
	}
}

static func get_enum_from_string(string_value: String):
	var upper_str = string_value.to_upper()
	if Name.has(upper_str):
		return Name[upper_str]
	else:
		return -1
