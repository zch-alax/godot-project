class_name FSM

extends Node

var states = {}
var current_state
var current_state_node: State
var previous_state

# 初始化，初始化states字典，获取父节点与有限状态机节点
func _ready():
	var object = get_parent()
	for state: State in get_children():
		states[state.name.to_lower()] = state
		state.fsm = self
		state.object = object
	
func update(delta):
	if not current_state:
		return
	current_state_node.update(delta)

func physics_update(delta):
	if not current_state:
		return
	current_state_node.physics_update(delta)

# 核心代码，用于改变状态	
func change_state(next_state):
	# 当前状态存在时，退出该状态
	if current_state:
		current_state_node.exit()
	
	previous_state = current_state
	current_state = next_state
	current_state_node = states[next_state]
	current_state_node.enter()
