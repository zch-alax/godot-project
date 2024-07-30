extends CharacterBody2D


var direction:
	set(value):
		if value == 0 or value == direction: return
		direction = value
		animated_sprite.flip_h = value == -1

@onready var animated_sprite = $AnimatedSprite2D
@onready var fsm = $FSM

func _ready():
	fsm.change_state("idle")


func _physics_process(delta):
	fsm.physics_update(delta)
