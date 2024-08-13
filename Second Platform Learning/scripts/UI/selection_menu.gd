extends CanvasLayer

@export var selection_container: Node
@export var enter_player: AudioStreamPlayer
@export var selection_player: AudioStreamPlayer

var selection_items: Array[Node]
var selection_index: int:
	set(value):
		selection_index = clampi(value, 0, selection_items.size() -1)
		for i in selection_items.size():
			selection_items[i].modulate.a = 1.0 if i == selection_index else 0.3

func _ready():
	selection_items = selection_container.get_children()
	selection_index = 0
	disable()
	
func enable():
	set_process_input(true)
	
func disable():
	set_process_input(false)	
	
func _input(event):
	if event.is_action_pressed("ui_down"):
		selection_index += 1
		selection_player.play()
	elif event.is_action_pressed("ui_up"):
		selection_index -= 1
		selection_player.play()
	elif event.is_action_pressed("ui_accept"):
		enter_player.play()
		var selection = selection_items[selection_index]
		if selection.has_method("select"):
			selection.select()
