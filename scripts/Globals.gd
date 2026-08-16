extends Node2D

var player_turn: int = 0
var team_turn: int = 0
var players_in_team: int = 3
var weapon_number: int = 0
var weapons_left: Array = [0]


func next_player(skip_player: bool = false):
	if skip_player:
		print("skip")
		player_turn += 1
		
		if player_turn > 2:
			player_turn = 0
	else:
		if team_turn == 1:
			if player_turn == 2:
				player_turn = 0
			else:
				player_turn += 1
		
		team_turn = (team_turn + 1) % 2
	
	print("player_turn ", player_turn, " team_turn ", team_turn)
	
	for player: Player in get_tree().get_nodes_in_group("Player"):
		player.next_player()
