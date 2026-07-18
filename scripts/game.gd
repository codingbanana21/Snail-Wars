class_name Game
extends Node2D

@onready var map: TileMapLayer = $Map


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip"):
		Globals.player_turn = (Globals.player_turn % 4) + 1


func remove_tile(tile_position: Vector2):
	map.set_cell(tile_position, 0, Vector2i(0, 1))
