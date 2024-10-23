extends Area2D

@export var box_prefab : PackedScene

var last_spawn_time = -999

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and Time.get_ticks_msec() - last_spawn_time > 500:
		last_spawn_time = Time.get_ticks_msec()
		scale.y = 0.5
		var box_object := box_prefab.instantiate() as Node2D
		
		box_object.position = Vector2(100 if randf() > 0.5 else -100, -175)
		var box_scale = randf_range(0.75, 1.25)
		var box_sprite = box_object.get_child(1) as Sprite2D
		box_sprite.modulate = Color(randf(), randf(), randf())
		box_sprite.scale *= box_scale
		
		var box_collider = box_object.get_child(0) as CollisionShape2D
		box_collider.shape.size *= box_scale
		
		get_tree().current_scene.add_child(box_object)
		
	
func _on_body_exited(body: Node2D) -> void:
	scale.y = 1
