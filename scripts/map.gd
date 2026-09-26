@tool
class_name Map
extends Node2D

@onready var map: TileMapLayer = $Map
@onready var image: Sprite2D = $Image


@export_tool_button("Make Map") var my_action := Callable(self, "make_map")

func _ready() -> void:
	Globals.player_turn = randi_range(0, Globals.players_in_team - 1)
	Globals.team_turn = randi_range(0, Globals.number_of_teams)
	Globals.next_player()
	#make_map()


func make_map():
	var data = image.get_texture().get_image()
	
	for x in image.texture.get_width():
		for y in image.texture.get_height():
			var pixelColor = data.get_pixel(x,y)
			var offset: Vector2i = Vector2i(x -128, y -256)
			
			if pixelColor == Color(0.0, 1.0, 0.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(0, 0))
				
			elif pixelColor == Color(1.0, 0.0, 0.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(1, 0))
				
			elif pixelColor == Color(0.0, 0.0, 1.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(2, 0))
				
			elif pixelColor == Color(1.0, 0.0, 1.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(3, 0))
				
			elif pixelColor == Color(1.0, 1.0, 1.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(6, 0))
				
			elif pixelColor == Color(0.0, 0.0, 0.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(5, 0))
				
			else:
				map.set_cell(offset, 0 ,Vector2i(0, 7))
				


func explode_tile(target_position: Vector2, power: int):
	var tile_position: Vector2 = round(target_position / 8.0)
	var explosion_accuracy: float = PI * 2
	
	for explosion_size in range(power):
		for number in range(explosion_accuracy * 16 * explosion_size):
			var tile: Vector2 = tile_position + Vector2(sin(number / explosion_accuracy) * explosion_size, cos(number / explosion_accuracy) * explosion_size)
			var tile_type: Vector2i = map.get_cell_atlas_coords(tile)
			
			if tile_type.y == 0:
				map.set_cell(tile, 0, tile_type + Vector2i(0, 1))
