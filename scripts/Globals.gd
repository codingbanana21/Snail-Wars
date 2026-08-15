extends Node2D

var player_turn: int = 0
var team_turn: int = 0
var players_in_team: int = 3
var weapon_number: int = 0
var weapons_left: Array = [0]


func _ready() -> void:
	player_turn = randi_range(0, players_in_team - 1)
	team_turn = randi_range(0, 1)
	next_player()


func next_player():
	if player_turn == 2:
		team_turn %= 2
		player_turn = 0
	else:
		player_turn += 1
	
	print(player_turn)
	print(team_turn)
	
	for player: Player in get_tree().get_nodes_in_group("Player"):
		player.next_player()
