class_name Map
extends Node2D

@onready var map: TileMapLayer = $Map
@onready var image: Sprite2D = $Image


func _ready() -> void:
	Globals.team_turn = randi_range(0, Globals.number_of_teams)
	image.texture = load("res://maps/map_"+Globals.map+".png") 
	make_map()
	Globals.next_player()


func make_map():
	var data = image.get_texture().get_image()
	var player_number: int = 0
	var team_colors: Array[Color]
	var teams: Array[int]
	
	for y in image.texture.get_width():
		for x in image.texture.get_height():
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
			elif pixelColor == Color(1.0, 1.0, 0.0, 1.0):
				var mine: Projectile = load("res://projectiles/super_mine.tscn").instantiate()
				mine.global_position = offset * 8
				add_child(mine)
			elif pixelColor.a != 0:
				if team_colors.find(pixelColor) == -1:
					if len(teams) >= Globals.number_of_teams:
						continue
					
					team_colors.append(pixelColor)
					teams.append(-1)
					Globals.teams_turns.append(0)
				
				var team_number: int = team_colors.find(pixelColor)
				
				if teams[team_number] >= Globals.players_in_team - 1:
					continue
				
				teams[team_number] += 1
				player_number = teams[team_number]
				
				var player: Player = load("res://scenes/player.tscn").instantiate()
				player.global_position = offset * 8
				player.team_color = pixelColor
				player.player_number = player_number
				player.team_number = team_number
				player.add_to_group("Player")
				add_child(player)
				
				player.team_label.text = "Team "+str(team_number)
			else:
				map.set_cell(offset, 0 ,Vector2i(0, 2))


func explode_tile(target_position: Vector2, power: int):
	var tile_position: Vector2 = round(target_position / 8.0)
	var explosion_accuracy: float = PI * 2
	
	for explosion_size in range(power):
		for number in range(explosion_accuracy * 16 * explosion_size):
			var tile: Vector2 = tile_position + Vector2(sin(number / explosion_accuracy) * explosion_size, cos(number / explosion_accuracy) * explosion_size)
			var tile_type: Vector2i = map.get_cell_atlas_coords(tile)
			
			if tile_type.y == 0:
				map.set_cell(tile, 0, tile_type + Vector2i(0, 1))
