extends Label

func select():
	Game.main.main_menu.hide()
	Game.main.main_menu.disable()
	Game.main.world.load_level("level_1")
	
