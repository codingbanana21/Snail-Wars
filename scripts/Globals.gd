extends Node2D

#const
const WEAPONS: Array[String] = ["rocket","grenade","drill","bomb","air_strike","drill_strike","tnt","bullet","teleporta","pumkin_grenade","present","cake_tnt","leaf","chicken","father_chrismas","spring"]
const WEAPONS_NAMES: Array[String] = ["Rocket Launcher","Grenade","Drill Rocket","Bomb","Air Strike","Drill Strike","TNT","Gun","Teleporta","Pumkin Grenade","Present Strike","Cake TNT","Healing Leaf","Chicken","Father Chrismas","Spring"]
const SAVE_PATH = "user://Save.tres"
const GAME_VERSION: float = 0.5
const WEAPON_SET: Array[Array] = [
	[[-1,-1,2,5,1,1,1,4,2,3,0,0,2,1,0,1]],
	[[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]],
	[[-1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
	[[-1,-1,3,5,0,0,2,4,3,3,0,1,0,2,0,2]],
	[[-1,-1,3,5,1,1,2,4,3,3,1,2,3,3,1,3]],
	]
const WEAPON_SET_NAMES: Array = ["Original","All","One of everthing","No Air","Crazy"]

#save data
var save_data: SaveDataResource = SaveDataResource.new()
var save_version: float
var saved_ip_address: String
var high_graphics: bool = true

#teams
var players_in_team: int
var number_of_teams: int
var alive_players: Array[Array]
var team_turns: Array[int]
var turn: Vector2i = Vector2i.ZERO

#settings
var player_hp: int
var water_level: int
var water_rise: int
var is_multiplayer: bool = false
var wind: int = 0
var teams_weapons: Array[Array]
var map: String = "1m"
var explosion_power: float = 1.0
var map_size_x: float = 1.0
var map_size_y: float = 1.0

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = 1000
	load_game()


@rpc("any_peer", "call_local", "reliable")
func next_player(skip_player: bool = false):
	Mouse.show()
	
	if !skip_player:
		wind = rng.randi_range(-4,4)
		water_level += water_rise
	
	if !multiplayer.is_server(): return
	
	turn.y = team_turns[turn.x]
	#print(team_turns)
	#print(turn.x)
	turn.x += 1
	
	if turn.x >= number_of_teams:
		turn.x = 0
		
		turn.y += 1
		if turn.y >= players_in_team:
			turn.y = 0
	var temp_turn: Vector2i = turn
	
	team_turns[turn.x] = turn.y
	
	while alive_players[turn.x][turn.y] == false:
		turn.y += 1
		if turn.y >= players_in_team:
			turn.y = 0
		
		if turn.y == temp_turn.y:
			turn.x += 1
			if turn.x >= number_of_teams:
				turn.x = 0
	
	for player: Player in get_tree().get_nodes_in_group("Player"):
		player.next_player.rpc(turn)


func save_game(force_save: bool = false):
	if save_version == GAME_VERSION or force_save:
		save_data.save_version = save_version
		save_data.saved_ip_address = saved_ip_address
		ResourceSaver.save(save_data, SAVE_PATH)


func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		save_data = ResourceLoader.load(SAVE_PATH).duplicate(true)
		save_version = save_data.save_version
		
		if save_version:
			if save_version < GAME_VERSION:
				print("Out of date save")
				save_version = GAME_VERSION
			elif save_version > GAME_VERSION:
				push_error("Save is to new is use")
				return
		else:
			push_warning("No save version")
			save_version = GAME_VERSION
		
		#set data
		saved_ip_address = save_data.saved_ip_address
	else:
		save_game(true)
		load_game()
