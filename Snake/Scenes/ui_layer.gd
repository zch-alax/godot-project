extends CanvasLayer

var buttonContainer: HBoxContainer

@onready var restart_button = $%Restart
@onready var quit_button = $%Quit

@onready var points_label = $PointsLabel
@onready var game_over_label = $GameOverLabel

@onready var snake: Snake = $"../Snake"

# Called when the node enters the scene tree for the first time.
func _ready():
	snake.on_game_over.connect(on_game_over)
	snake.on_point_scored.connect(on_point_scored)
	buttonContainer = get_node("BoxContainer")
	restart_button.pressed.connect(on_restart_pressed)
	quit_button.pressed.connect(on_quit_pressed)

func on_game_over():
	buttonContainer.visible = true
	game_over_label.visible = true
	
func on_point_scored(points: int):
		points_label.text = "Points: %d" % points

func on_restart_pressed():
	get_tree().reload_current_scene()
	
func on_quit_pressed():
	get_tree().quit()
