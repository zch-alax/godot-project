extends Node
class_name FSM

var states = {}
var current_state
var current_state_node: State
var previous_state

# 初始化
func _ready():
	var parent =  get_parent()
	var children = get_children()
	for child in children:
		if child is State:
			states[child.name.to_lower()] = child
			child.object = parent
			child.fsm = self
			
func update(delta):
	if not current_state: return
	current_state_node.update(delta)
	
func physics_update(delta):
	if not current_state: return
	current_state_node.physics_update(delta)
	
func change_state(next_state):
	if current_state:
		current_state_node.exit()
		
	previous_state = current_state
	current_state = next_state
	current_state_node = states[current_state]
	current_state_node.enter()
