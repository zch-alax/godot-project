extends Node

signal transitioned(state_name)

@export var initial_state := NodePath()

@onready var state: State = get_node_or_null(initial_state)

func _ready():
	for child in get_children():
		child.state_machine = self
	state.enter()
	
func _unhandled_input(event):
	state.handle_input(event)
	
func _process(delta):
	state.update(delta)
	
func _physics_process(delta):
	state.physics_update(delta)
	
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return
	
	state.exit()
	state = get_node_or_null(target_state_name)
	state.enter(msg)
	transitioned.emit(state.name)
	
