extends Node2D

var mouse_position: Vector2 = Vector2.ZERO
var player_turn: int = 1
var players: int = 6
var weapon_number: int = 0
var weapons_left: Array = [0]


func _ready() -> void:
	player_turn = randi_range(1, players)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position += event.relative


func next_player():
	player_turn = (player_turn % players) + 1
	
	for player: Player in get_tree().get_nodes_in_group("Player"):
		player.next_player()
