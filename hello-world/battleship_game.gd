extends Node2D


# Battleship Game

const SHIP = 0
const SHIP_HIT = 1
const WATER_HIT = 2

var board = {}

func initialize():
	board[Vector2(1, 1)] = SHIP
	board[Vector2(1, 2)] = SHIP
	board[Vector2(1, 3)] = SHIP

func missile(pos):
	if pos in board: # Something at that position.
		if board[pos] == SHIP: # There was a ship! hit it.
			board[pos] = SHIP_HIT
		else:
			print("Already hit here!") # Hey dude you already hit here.
	else: # Nothing, mark as water.
		board[pos] = WATER_HIT

func game():
	initialize()
	missile(Vector2(1, 1))
	missile(Vector2(5, 8))
	missile(Vector2(2, 3))
