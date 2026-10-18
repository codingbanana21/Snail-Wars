extends Node2D

var high_fps_mode: bool = false
var teams_turns: Array[int]
var team_turn: int = -1
var players_in_team: int
var number_of_teams: int
var player_hp: int
var water_level: int
var water_rise: int
var is_multiplayer: bool = false
var wind: int = 0
var teams_weapons: Array[Array]
var map: String = "1m"

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = 1000


@rpc("any_peer", "call_local", "reliable")
func next_player(skip_player: bool = false):
	if !skip_player:
		wind = rng.randi_range(-4,4)
		water_level += water_rise
	
	if !multiplayer.is_server(): return
	
	Mouse.show()
	
	if !skip_player:
		team_turn = (team_turn + 1) % number_of_teams
	
	teams_turns[team_turn] = (teams_turns[team_turn] + 1) % players_in_team
	
	for player: Player in get_tree().get_nodes_in_group("Player"):
		player.next_player.rpc(teams_turns, team_turn)
