class_name Game
extends Node2D

@onready var h_slider: HSlider = $HSlider
@onready var per_team_label: Label = $PerTeamLabel


func _process(delta: float) -> void:
	per_team_label.text = str(int(h_slider.value)) + " Player"
	Globals.players_in_team = int(h_slider.value)


func _on_map_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://scenes/map_1.scn")


func _on_map_button_2_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://scenes/map_2.scn")
