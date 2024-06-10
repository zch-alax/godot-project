extends CharacterBody2D

signal health_depleted

const SPEED := 600
const DAMAGE_RATE := 5.0

var health := 100.0
@onready var progress_bar = %ProgressBar

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
	
	
	if direction:
		$HappyBoo.play_walk_animation()
	else:
		$HappyBoo.play_idle_animation()
		
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		progress_bar.value = health
		if health <= 0.0:
			health_depleted.emit()
