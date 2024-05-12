extends Button

# 自定义信号
signal mySignal(a, b)

func _ready():
	self.connect("mySignal", Callable(self, "onMySignalCallBack"))
	self.connect("pressed", Callable(self, "onButton"))
	$"../DisConnectSignalButton".connect("pressed", Callable(self, "disConnectButton"))
	# 上下两种方式均可，只是呈现不同的方式
	
	# $"../MySignal".connect("mySignal", Callable($"../MySignal", "onMySignalCallBack"))
	# $"../MySignal".connect("pressed", Callable($"../MySignal", "onButton"))
	pass

func onMySignalCallBack(a, b):
	print("a: " + str(a))
	print("b: " + str(b))
	pass

func onButton():
	emit_signal("mySignal", 1, 2)
	pass
	
func disConnectButton():
	disconnect("mySignal", Callable(self, "onMySignalCallBack"))
	pass
