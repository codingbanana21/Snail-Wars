class_name Game
extends Node2D

@onready var per_team_h_slider: HSlider = %PerTeamHSlider
@onready var per_team_label: Label = %PerTeamLabel
@onready var weapons_h_slider: HSlider = %WeaponsHSlider
@onready var weapons_label: Label = %WeaponsLabel
@onready var teams_h_slider: HSlider = %TeamsHSlider
@onready var teams_label: Label = %TeamsLabel


func _process(delta: float) -> void:
	per_team_label.text = str(int(per_team_h_slider.value)) + " players per team"
	Globals.players_in_team = int(per_team_h_slider.value)
	
	teams_label.text = str(int(teams_h_slider.value)) + " Teams"
	Globals.number_of_teams = int(teams_h_slider.value)
	
	weapons_label.text = "Weapon set "+str(int(weapons_h_slider.value))


func load_map(level: String = "1m"):
	if int(weapons_h_slider.value) == 1:
		Globals.teams_weapons = [[-1,-1,2,4,1,1,1,1,0,-1,3]]
	elif int(weapons_h_slider.value) == 2:
		Globals.teams_weapons = [[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
	elif int(weapons_h_slider.value) == 3:
		Globals.teams_weapons = [[1,1,1,1,1,1,1,1,1,1,1]]
	elif int(weapons_h_slider.value) == 4:
		Globals.teams_weapons = [[-1,-1,0,0,0,0,0,0,0,-1,0]]
	
	for i in range(Globals.number_of_teams-1):
		Globals.teams_weapons.append([])
		for k in range(len(Globals.teams_weapons[0])):
			Globals.teams_weapons[i+1].append(Globals.teams_weapons[0][k])
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://maps/map_"+level+".scn")


func _on_map_1b_button_pressed() -> void:
	load_map("1b")


func _on_map_2b_button_pressed() -> void:
	load_map("2b")


func _on_map_1m_button_pressed() -> void:
	load_map("1m")


func _on_map_1s_button_pressed() -> void:
	load_map("1s")


func _on_map_2s_button_pressed() -> void:
	load_map("2s")
