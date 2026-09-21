class_name Game
extends Node2D

@onready var h_slider: HSlider = $HSlider
@onready var per_team_label: Label = $PerTeamLabel


func _process(delta: float) -> void:
	per_team_label.text = str(int(h_slider.value)) + " Player"
	Globals.players_in_team = int(h_slider.value)


func load_map(level: int = 1):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://maps/map_"+str(level)+".scn")


func _on_map_button_pressed() -> void:
	load_map(1)


func _on_map_button_2_pressed() -> void:
	load_map(2)


func _on_map_button_3_pressed() -> void:
	load_map(3)


func _on_map_button_4_pressed() -> void:
	load_map(4)
