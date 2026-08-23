extends Node2D

var player_turn: int = 0
var team_turn: int = 0
var players_in_team: int = 3
var number_of_teams: int = 2
var teams_weapons: Array[Array] = [[-1,-1,3,2,1,1,1], [-1,-1,3,2,1,1,1]]


func next_player(skip_player: bool = false):
	#player turn and teams picking
	if skip_player:
		player_turn += 1
		
		if player_turn >= players_in_team:
			player_turn = 0
	else:
		team_turn += 1
		
		if team_turn >= number_of_teams:
			if player_turn >= players_in_team - 1:
				team_turn = 0
				player_turn = 0
			else:
				team_turn = 0
				player_turn += 1
	
	for player: Player in get_tree().get_nodes_in_group("Player"):
		player.next_player()
