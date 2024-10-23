extends CanvasLayer

@export var player: CharacterBody2D

func _save() -> void:
	var data = SceneData.new()
	# 保存人物位置与朝向
	data.player_position = player.global_position
	data.is_facing_left = player.get_child(0).flip_h
	
	# 保存所有箱子节点
	var boxes = get_tree().get_nodes_in_group("Box")
	for box in boxes:
		var box_scene = PackedScene.new()
		box_scene.pack(box)
		data.box_arr.append(box_scene)
	# .res格式 查看文件会是乱码，有更好的数据安全和性能
	# .tres格式 查看文件不会是乱码，主要用于DEBUG
	ResourceSaver.save(data, "user://save.tres")


func _load() -> void:
	var data: SceneData = ResourceLoader.load("user://save.tres")
	# 读取人物位置与朝向
	player.global_position = data.player_position
	player.get_child(0).flip_h = data.is_facing_left

	# 读取所有箱子节点
	for box in get_tree().get_nodes_in_group("Box"):
		box.queue_free()
	
	var boxes = data.box_arr
	var current_scene = get_tree().current_scene
	for box in boxes:
		current_scene.add_child(box.instantiate())
