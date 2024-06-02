extends Node

# 我们使用 @export var mob_scene: PackedScene 来允许我们选择要实例化的 Mob 场景
@export var mob_scene: PackedScene
var score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUB.game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUB.update_score(score)
	$HUB.show_message("Get Ready")
	# call_group() 函数调用组中每个节点上的删除函数——让每个怪物删除其自身
	get_tree().call_group("mobs", "queue_free")
	$Music.play()

func _on_score_timer_timeout():
	score += 1
	$HUB.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout():
	# 创建新实例
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	# PI 圆周率，表示转半圈的弧度
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location.position
	
	direction += randf_range(-PI /4, PI / 4)
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)
