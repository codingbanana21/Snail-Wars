extends Node2D

var mouse_position: Vector2 = Vector2.ZERO
var player_turn: int = 1
var players: int = 4


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position += event.relative


func next_player():
	player_turn = (player_turn % players) + 1
