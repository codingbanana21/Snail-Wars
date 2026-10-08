class_name Game
extends Node2D

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


func _process(delta: float) -> void:
	per_team_label.text = str(int(per_team_h_slider.value)) + " Players Per Team"
	Globals.players_in_team = int(per_team_h_slider.value)
	
	teams_label.text = str(int(teams_h_slider.value)) + " Teams"
	Globals.number_of_teams = int(teams_h_slider.value)
	
	player_hp_label.text = str(int(player_hph_slider.value)) + " Player HP"
	Globals.player_hp = int(player_hph_slider.value)
	
	water_level_label.text = str(int(water_level_h_slider.value)) + " Water Level"
	Globals.water_level = -int(water_level_h_slider.value)
	
	weapons_label.text = "Weapon set "+str(int(weapons_h_slider.value))


func load_map(map: String = "b1"):
	Globals.map = map
	
	if int(weapons_h_slider.value) == 1:
		Globals.teams_weapons = [[-1,-1,2,3,1,1,1,1,2,1]]
	elif int(weapons_h_slider.value) == 2:
		Globals.teams_weapons = [[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
	elif int(weapons_h_slider.value) == 3:
		Globals.teams_weapons = [[-1,-1,2,3,0,0,-1,3,4,2]]
	
	for i in range(Globals.number_of_teams -1):
		Globals.teams_weapons.append([])
		for k in range(len(Globals.teams_weapons[0])):
			Globals.teams_weapons[i+1].append(Globals.teams_weapons[0][k])
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Mouse.can_move = true
	get_tree().change_scene_to_file("res://maps/game.tscn")


func _on_b_1_button_pressed() -> void:
	load_map("b1")


func _on_m_1_button_pressed() -> void:
	load_map("m1")


func _on_m_2_button_pressed() -> void:
	load_map("m2")


func _on_b_2_button_pressed() -> void:
	load_map("b2")


func _on_m_3_button_pressed() -> void:
	load_map("m3")


func _on_s_1_button_pressed() -> void:
	load_map("s1")


func _on_s_2_button_pressed() -> void:
	load_map("s2")


func _on_g_1_button_pressed() -> void:
	load_map("g1")
