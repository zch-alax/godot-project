extends Node2D

@onready var main_menu = $MainMenu
@onready var pause_menu = $PauseMenu
@onready var world = $World

func _ready():
	Game.main = self
