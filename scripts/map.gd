class_name Map
extends Node2D

@onready var map: TileMapLayer = $Map


func _ready() -> void:
	Globals.player_turn = randi_range(0, Globals.players_in_team - 1)
	Globals.team_turn = randi_range(0, Globals.number_of_teams)
	Globals.next_player()


func explode_tile(target_position: Vector2, power: int):
	var tile_position: Vector2 = round(target_position / 4.0)
	var explosion_accuracy: float = PI * 2
	
	for explosion_size in range(power):
		for number in range(explosion_accuracy * 8 * explosion_size):
			var tile = tile_position + Vector2(sin(number / explosion_accuracy) * explosion_size, cos(number / explosion_accuracy) * explosion_size)
			var tile_type = map.get_cell_atlas_coords(tile)
			
			if tile_type.y < 3:
				map.set_cell(tile, 0, tile_type + Vector2i(0, 3))
