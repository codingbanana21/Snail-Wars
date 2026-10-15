class_name MainMenu
extends Node2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var menu: Node2D = $Menu
@onready var ip: TextEdit = %IP
@onready var per_team_h_slider: HSlider = %PerTeamHSlider
@onready var per_team_label: Label = %PerTeamLabel
@onready var weapons_h_slider: HSlider = %WeaponsHSlider
@onready var weapons_label: Label = %WeaponsLabel
@onready var teams_h_slider: HSlider = %TeamsHSlider
@onready var teams_label: Label = %TeamsLabel
@onready var player_hph_slider: HSlider = %PlayerHPHSlider
@onready var player_hp_label: Label = %PlayerHPLabel
@onready var water_level_h_slider: HSlider = %WaterLevelHSlider
@onready var water_level_label: Label = %WaterLevelLabel

const PORT = 3100

var peer = ENetMultiplayerPeer.new()


func _ready() -> void:
	multiplayer_spawner.spawn_function = load_map


func _process(_delta: float) -> void:
	per_team_label.text = str(int(per_team_h_slider.value)) + " Players Per Team"
	Globals.players_in_team = int(per_team_h_slider.value)
	
	teams_label.text = str(int(teams_h_slider.value)) + " Teams"
	Globals.number_of_teams = int(teams_h_slider.value)
	
	player_hp_label.text = str(int(player_hph_slider.value)) + " Player HP"
	Globals.player_hp = int(player_hph_slider.value)
	
	water_level_label.text = str(int(water_level_h_slider.value)) + " Water Level"
	Globals.water_level = -int(water_level_h_slider.value)
	
	weapons_label.text = "Weapon set "+str(int(weapons_h_slider.value))


func load_map(inputs: Dictionary = {"multiplayer":false,"map":"m1"}):
	Globals.map = inputs["map"]
	
	if int(weapons_h_slider.value) == 1:
		Globals.teams_weapons = [[-1,-1,2,3,1,1,1,1,2,1,1]]
	elif int(weapons_h_slider.value) == 2:
		Globals.teams_weapons = [[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
	elif int(weapons_h_slider.value) == 3:
		Globals.teams_weapons = [[-1,-1,2,3,0,0,-1,3,4,2,1]]
	
	for i in range(Globals.number_of_teams -1):
		Globals.teams_weapons.append([])
		for k in range(len(Globals.teams_weapons[0])):
			Globals.teams_weapons[i+1].append(Globals.teams_weapons[0][k])
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu.hide()
	Mouse.can_move = true
	var map_file = preload("res://maps/map.tscn").instantiate()
	
	if inputs["multiplayer"]:
		Globals.is_multiplayer = true
		return map_file
	else:
		add_child(map_file)


func _on_server_pressed() -> void:
	ip.text = str(get_upnp())
	
	peer.create_server(PORT,1)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(
		func(_id):
			multiplayer_spawner.spawn({"multiplayer":true,"map":"m1"})
	)


func _on_client_pressed() -> void:
	var ip_address = ip.text
	
	if ip_address == "":
		ip_address = "localhost"
	
	if ip_address.is_valid_ip_address() or ip_address == "localhost":
		peer.create_client(ip_address, PORT)
		multiplayer.multiplayer_peer = peer


func get_upnp():
	var upnp = UPNP.new()
	var discorer_result = upnp.discover()
	if discorer_result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			var map_result = upnp.add_port_mapping(9999,0,"SnailWars","UDP", 10800)
			if map_result == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(9999,0,"")
	
	upnp.delete_port_mapping(9999,"UDP")
	return upnp.query_external_address()


func _on_b_1_button_pressed() -> void:
	load_map({"multiplayer":false,"map":"b1"})


func _on_b_2_button_pressed() -> void:
	load_map({"multiplayer":false,"map":"b2"})


func _on_m_1_button_pressed() -> void:
	load_map({"multiplayer":false,"map":"m1"})

func _on_m_2_button_pressed() -> void:
	load_map({"multiplayer":false,"map":"m2"})


func _on_m_3_button_pressed() -> void:
	load_map({"multiplayer":false,"map":"m3"})


func _on_s_1_button_pressed() -> void:
	load_map({"multiplayer":false,"map":"s1"})


func _on_s_2_button_pressed() -> void:
	load_map({"multiplayer":false,"map":"s2"})


func _on_g_1_button_pressed() -> void:
	load_map({"multiplayer":false,"map":"g1"})
