extends Node2D

var teams_turns: Array[int]
var team_turn: int = -1
var players_in_team: int = 4
var number_of_teams: int = 2
var player_hp: int = 100
var water_level: int = -100
var wind: int = 0
var teams_weapons: Array[Array]
var map: String


func next_player(skip_player: bool = false):
	wind = randi_range(-5,5)
	Mouse.show()
	
	if !skip_player:
		team_turn = (team_turn + 1) % number_of_teams
	
	teams_turns[team_turn] = (teams_turns[team_turn] + 1) % players_in_team
	
	for player: Player in get_tree().get_nodes_in_group("Player"):
		player.next_player()
