extends Node2D

func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSig)
	

func DialogicSig(dia_signal: String):
	if dia_signal == "get_apple":
		print("I get an apple")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("E"):
		Dialogic.start("ChunkGiving")
