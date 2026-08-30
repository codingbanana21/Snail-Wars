class_name Game
extends Node2D

@onready var map: TileMapLayer = $Map


func _ready() -> void:
	Globals.player_turn = randi_range(0, Globals.players_in_team - 1)
	Globals.team_turn = randi_range(0, Globals.number_of_teams)
	Globals.next_player()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip"):
		Globals.next_player()


func remove_tile(tile_position: Vector2):
	var map_tile = map.get_cell_atlas_coords(tile_position)
	
	if map_tile.y < 3:
		map.set_cell(tile_position, 0, map_tile+Vector2i(0, 3))
	
	#map.set_cell(tile_position, 0, Vector2i(0, 4))
