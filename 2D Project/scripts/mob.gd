extends CharacterBody2D

const SPEED = 300

var health = 10

@onready var player = $"../Player"

@onready var slime = $Slime

func _ready():
	slime.play_walk()

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED
	move_and_slide()

func take_damage():
	slime.play_hurt()
	health -= 1
	
	if health == 0:
		queue_free()
		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
