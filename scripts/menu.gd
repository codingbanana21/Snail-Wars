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

const SERVER_PORT = 3100
const CONNECT_TIMEOUT: float = 5.0

var peer = ENetMultiplayerPeer.new()
var upnp


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
	var ip_address = upnp_setup(SERVER_PORT)
	#var ip_address = IP.get_local_addresses()[1]
	
	if !ip_address.is_valid_ip_address():
		push_error("There was a error when creating the server ", ip_address)
		ip.text = "There was a error when creating the server " + str(ip_address)
		return
	else:
		ip.text = ip_address 
	
	var serr = peer.create_server(SERVER_PORT, 1)
	
	if serr != OK:
		push_error("create_server failed: ", serr)
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(
		func(_id):
			multiplayer_spawner.spawn({"multiplayer":true,"map":"m1"})
	)


func _on_client_pressed() -> void:
	var ip_address = ip.text.strip_edges()
	if ip_address == "":
		ip_address = "localhost"
	
	if !ip_address.is_valid_ip_address() and !ip_address == "localhost":
		push_error("IP address is invalid ", ip_address)
		return
	
	var new_peer = ENetMultiplayerPeer.new()
	var cerr = new_peer.create_client(ip_address, SERVER_PORT)
	
	if cerr != OK:
		push_error("create_client failed: ", cerr)
		return
	
	if !multiplayer.connected_to_server.is_connected(_on_connected):
		multiplayer.connected_to_server.connect(_on_connected)
		multiplayer.connection_failed.connect(_on_connection_failed)
	
	peer = new_peer
	multiplayer.multiplayer_peer = new_peer
	print("trying to connect to ", ip_address)
	
	await get_tree().create_timer(CONNECT_TIMEOUT).timeout
	if new_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		push_error("Connection timed out after %d seconds" % CONNECT_TIMEOUT)
		new_peer.close()
		if multiplayer.multiplayer_peer == new_peer:
			multiplayer.multiplayer_peer = null


func _on_connected() -> void:
	print("connected")


func _on_connection_failed() -> void:
	push_error("Can't connect to ", ip.text)


func upnp_setup(server_port):
	upnp = UPNP.new()
	
	var err = upnp.discover(5000, 2, "InternetGatewayDevice")
	
	if err != UPNP.UPNP_RESULT_SUCCESS:
		push_error("UPNP discover failed ", err)
		return ""
	
	var gatway = upnp.get_gateway()
	if !upnp.get_gateway() or !gatway.is_valid_gateway():
		push_error("UPNP: no valid gateway")
		return ""
	
	var map_err = upnp.add_port_mapping(server_port, server_port, "snailwars", "UDP", 0)
	if map_err != UPNP.UPNP_RESULT_SUCCESS:
		push_warning("Permanent mapping failed, retrying with non-permanent")
		map_err = upnp.add_port_mapping(server_port, server_port, "snailwars", "UDP", 3600)
		
		if map_err != UPNP.UPNP_RESULT_SUCCESS:
			push_error("UPNP mapping failed")
			return
	
	var addr = upnp.query_external_address()
	return addr


func _exit_tree() -> void:
	if upnp:
		upnp.delete_port_mapping(SERVER_PORT, "UDP")


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
