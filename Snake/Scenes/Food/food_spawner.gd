extends Node

class_name FoodSpawner

@export var walls: Walls
@export var food_scene: PackedScene

var food_position: Vector2

var food: Sprite2D

const BODY_SEGMENT_SIZE = 32

func _ready():
	spwan_food()

func spwan_food():
	food = food_scene.instantiate()
	# get random values with 32 increments
	var x_pos = round(randi_range(walls.top_left_corner.x + BODY_SEGMENT_SIZE, walls.bottom_right_corner.x - BODY_SEGMENT_SIZE) / BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	var y_pos = round(randi_range(walls.top_left_corner.y + BODY_SEGMENT_SIZE, walls.bottom_right_corner.y - BODY_SEGMENT_SIZE) / BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	add_child(food)
	food_position = Vector2(x_pos, y_pos)
	food.position = food_position
	
	
func destory_food():
	if food != null:
		food.queue_free()
