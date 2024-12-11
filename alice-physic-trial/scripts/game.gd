extends Node2D

@onready var main_menu: CanvasLayer = $MainMenu
@onready var chapters: Node2D = $Chapters
	

func _ready() -> void:
	Main.game = self
