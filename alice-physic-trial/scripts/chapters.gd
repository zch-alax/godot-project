extends Node2D

var chapter = null

@export var chapters: Dictionary

func load_chapter(chapter_name: String):
	chapter = load(chapters[chapter_name]).instantiate()
	add_child(chapter)
	
func unload_chapter():
	chapter.queue()
	chapter = null
