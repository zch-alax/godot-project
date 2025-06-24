class_name Evidence

extends Node

enum Name {
	BADGE,
	REPORT,
	STATUE
}

const EVIDENCE_DETAIL := {
	Name.BADGE: {
		"name": "律师徽章",
		"detail": "如果没有这个东西，\n就不会有人承认我是律师。",
		"sprite": preload("res://assets/images/evidence/1.png"),
		"is_add_item": true
	},
	Name.REPORT: {
		"name": "高日  美佳的解剖记录",
		"detail": "死亡时间为7月31日\n下午4时到5时之间。受到\n钝器一击，失血过多死亡。",
		"sprite": preload("res://assets/images/evidence/2.png"),
		"is_add_item": true
	},
	Name.STATUE: {
		"name": "小雕像",
		"detail": "“沉思者”造型的装饰品。\n相当沉重。",
		"sprite": preload("res://assets/images/evidence/25.png"),
		"is_add_item": false
	}
}

static func get_enum_from_string(evidence_name: String):
	var upper_name = evidence_name.to_upper()
	if Name.has(upper_name):
		return Name[upper_name]
	else:
		return -1
