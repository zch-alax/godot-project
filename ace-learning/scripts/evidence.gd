class_name Evidence

extends Node

enum {
	BADGE,
	REPORT
}

const EVIDENCE_DETAIL := {
	BADGE: {
		"name": "律师徽章",
		"detail": "如果没有这个东西，\n就不会有人承认我是律师。",
		"sprite": preload("res://assets/images/evidence/1.png")
	},
	REPORT: {
		"name": "高日  美佳的解剖记录",
		"detail": "死亡时间为7月31日\n下午4时到5时之间。受到\n钝器一击，失血过多死亡。",
		"sprite": preload("res://assets/images/evidence/2.png")
	}
}
