extends CanvasLayer


signal start_time

# 显示一条临时消息，比如“Get Ready”
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	

func game_over():
	# 显示 2 秒“Game Over”
	show_message("Game Over")
	await $MessageTimer.timeout
	
	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# 暂停一会儿之后再显示“Start”按钮
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$StartButton.hide()
	start_time.emit()


func _on_message_timer_timeout():
	$Message.hide()
