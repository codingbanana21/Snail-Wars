extends Node

enum TurnState {IDLE, AIMING, FIRED, RESOLVING, ENDING}
enum {NAME,DEFAULT,NO_AIR,CRAZY,EVERYTHING}

const WEAPON_SET_NAMES: Array = ["Default","No Air","Crazy","Everything"]
const WEAPONS: Dictionary = {
	"rocket":{NAME:"Rocket Launcher", DEFAULT:-1, NO_AIR:-1, CRAZY:-1, EVERYTHING:-1},
	"grenade":{NAME:"Grenade", DEFAULT:-1, NO_AIR:-1, CRAZY:-1, EVERYTHING:-1},
	"bomb":{NAME:"Bomb", DEFAULT:5, NO_AIR:5, CRAZY:5, EVERYTHING:-1},
	"drill_rocket":{NAME:"Drill Rocket", DEFAULT:2, NO_AIR:3, CRAZY:3, EVERYTHING:-1},
	"pumpkin_grenade":{NAME:"Pumpkin Grenade", DEFAULT:3, NO_AIR:3, CRAZY:4, EVERYTHING:-1},
	"healing_leaf":{NAME:"Healing Leaf", DEFAULT:2, NO_AIR:0, CRAZY:3, EVERYTHING:-1},
	"bullet":{NAME:"Gun", DEFAULT:5, NO_AIR:5, CRAZY:5, EVERYTHING:-1},
	"pan":{NAME:"The Pan", DEFAULT:1, NO_AIR:2, CRAZY:2, EVERYTHING:-1},
	"air_strike":{NAME:"Air Strike", DEFAULT:1, NO_AIR:0, CRAZY:1, EVERYTHING:-1},
	"drill_strike":{NAME:"Drill Strike", DEFAULT:1, NO_AIR:0, CRAZY:1, EVERYTHING:-1},
	"present_strike":{NAME:"Present Strike", DEFAULT:0, NO_AIR:0, CRAZY:1, EVERYTHING:-1},
	"chicken":{NAME:"Chicken", DEFAULT:1, NO_AIR:2, CRAZY:3, EVERYTHING:-1},
	"father_christmas":{NAME:"Father Christmas", DEFAULT:0, NO_AIR:0, CRAZY:0, EVERYTHING:-1},
	"tnt":{NAME:"TNT", DEFAULT:1, NO_AIR:2, CRAZY:3, EVERYTHING:-1},
	"cake_tnt":{NAME:"Cake TNT", DEFAULT:0, NO_AIR:1, CRAZY:2, EVERYTHING:-1},
	"land_mine":{NAME:"Land Mine", DEFAULT:2, NO_AIR:2, CRAZY:3, EVERYTHING:-1},
	"super_mine":{NAME:"Super Mine", DEFAULT:0, NO_AIR:0, CRAZY:0, EVERYTHING:-1},
	"teleporter":{NAME:"Teleporter", DEFAULT:2, NO_AIR:3, CRAZY:4, EVERYTHING:-1},
	"teleporter_pad":{NAME:"Teleporter Pad", DEFAULT:1, NO_AIR:0, CRAZY:2, EVERYTHING:-1},
	"spring":{NAME:"Spring", DEFAULT:2, NO_AIR:3, CRAZY:4, EVERYTHING:-1},
	"pick_hammer":{NAME:"Pick Hammer", DEFAULT:2, NO_AIR:0, CRAZY:3, EVERYTHING:-1},
	"blow_torch":{NAME:"Blow Torch", DEFAULT:3, NO_AIR:0, CRAZY:4, EVERYTHING:-1},
	"mud_ball":{NAME:"Mud Ball", DEFAULT:2, NO_AIR:3, CRAZY:3, EVERYTHING:-1},
	"laser":{NAME:"Laser", DEFAULT:0, NO_AIR:0, CRAZY:2, EVERYTHING:-1},
	"blow_torch_pro":{NAME:"Blow Torch Pro", DEFAULT:0, NO_AIR:0, CRAZY:0, EVERYTHING:-1},
}

#save data
const SAVE_PATH = "user://Save.tres"
const GAME_VERSION: float = 0.7
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
var water_level: float
var water_rise: float
var is_multiplayer: bool = false
var wind: float = 0.0
var teams_weapons: Array[Array]
var map: String = "1m"
var explosion_power: float = 1.0
var wind_speed: float = 5.0
var gravity: float = 1.0

#test settings
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
		wind = snapped(rng.randf_range(-wind_speed, wind_speed), 0.5)
		water_level += water_rise
	
	if !multiplayer.is_server(): return
	
	turn.y = team_turns[turn.x]
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
