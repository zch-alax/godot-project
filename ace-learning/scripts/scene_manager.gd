extends Node2D

signal transition_out_completed
signal transition_in_completed

var transition_layer: CanvasLayer
var transition_rect: ColorRect
var transition_time: float = 0.7

func _ready() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100
	transition_rect = ColorRect.new()
	transition_rect.color = Color.BLACK
	transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_rect.visible = false
	transition_layer.add_child(transition_rect)
	get_tree().root.add_child.call_deferred(transition_layer)

func transition_out(effect: String = "fade"):
	transition_rect.visible = true
	match effect:
		"fade":
			fade_out()
		_:
			fade_out()
			
func transition_in(effect: String = "fade"):
	match effect:
		"fade":
			fade_in()
		_:
			fade_in()

func fade_out():
	var tween := create_tween()
	transition_rect.modulate.a = 0
	transition_rect.z_index = 999
	
	tween.tween_property(transition_rect, "modulate:a", 1.0, transition_time)
	tween.tween_callback(func(): transition_out_completed.emit())

func fade_in():
	var tween := create_tween()
	transition_rect.modulate.a = 1.0
	transition_rect.z_index = 999
	
	tween.tween_property(transition_rect, "modulate:a", 0.0, transition_time)
	tween.tween_callback(func(): 
		transition_rect.visible = false
		transition_in_completed.emit())

func change_scene(path: String):
	get_tree().change_scene_to_file(path)
