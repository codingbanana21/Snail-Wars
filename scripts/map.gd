class_name Map
extends Node2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var map: TileMapLayer = $Map
@onready var image: Sprite2D = $Image
@onready var water: Polygon2D = $Water
@onready var wind: HScrollBar = %Wind

var id


func _enter_tree() -> void:
	set_multiplayer_authority(int(id))


func _ready() -> void:
	multiplayer_spawner.spawn_function = add_player
	
	Globals.team_turn = randi_range(0, Globals.number_of_teams)
	image.texture = load("res://maps/map_"+Globals.map+".png") 
	make_map()
	Globals.next_player()


func _process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	wind.value = Globals.wind
	water.global_position.y = Globals.water_level + cos(Engine.get_physics_frames() / 100.0) * 20
	water.global_position.x = sin(Engine.get_physics_frames() / 100.0) * 50


func make_map():
	var data = image.get_texture().get_image()
	var player_number: int = 0
	var team_colors: Array[Color]
	var teams: Array[int]
	
	for y in image.texture.get_width():
		for x in image.texture.get_height():
			var pixel_color = data.get_pixel(x,y)
			var offset: Vector2i = Vector2i(x -128, y -256)
			
			if pixel_color == Color(0.0, 1.0, 0.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(4 * randi_range(0,1), 0))
			elif pixel_color == Color(1.0, 0.0, 0.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(1 + 4 * randi_range(0,1), 0))
			elif pixel_color == Color(0.0, 0.0, 1.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(2 + 4 * randi_range(0,1), 0))
			elif pixel_color == Color(1.0, 0.0, 1.0, 1.0):
				map.set_cell(offset, 0 ,Vector2i(3, 0))
			elif pixel_color == Color(1.0, 1.0, 0.0, 1.0):
				var mine: Projectile
				if Globals.map == "g1":
					mine = load("res://projectiles/super_mine.tscn").instantiate()
				else:
					mine = load("res://projectiles/mine.tscn").instantiate()
				
				mine.global_position = offset * 8
				add_child(mine)
			elif pixel_color.a != 0:
				if team_colors.find(pixel_color) == -1:
					if len(teams) >= Globals.number_of_teams:
						continue
					
					team_colors.append(pixel_color)
					teams.append(-1)
					Globals.teams_turns.append(0)
				
				var team_number: int = team_colors.find(pixel_color)
				
				if teams[team_number] >= Globals.players_in_team - 1:
					continue
				
				teams[team_number] += 1
				player_number = teams[team_number]
				
				if !is_multiplayer_authority(): continue
				
				multiplayer_spawner.spawn({"id":id,
					"global_position":offset,
					"team_color":pixel_color,
					"player_number":player_number,
					"team_number":team_number,
					})
			else:
				map.set_cell(offset, 0 ,Vector2i(0, 2))


func add_player(inputs: Dictionary = {"id":1,
		"global_position":Vector2.ZERO,
		"team_color":Color(),
		"player_number":0,
		"team_number":0,
		}):
	var player: Player = load("res://scenes/player.tscn").instantiate()
	player.id = inputs["id"]
	player.global_position = inputs["global_position"] * 8
	player.team_color = inputs["team_color"]
	player.player_number = inputs["player_number"]
	player.team_number = inputs["team_number"]
	player.add_to_group("Player")
	return player
	
	#player.team_label.text = "Team "+str(team_number)


@rpc("any_peer","reliable","call_local")
func explode_tile(target_position: Vector2, power: int):
	var tile_position: Vector2 = round(target_position / 8.0)
	var explosion_accuracy: float = PI * 2
	
	for explosion_size in range(power):
		for number in range(explosion_accuracy * 16 * explosion_size):
			var tile: Vector2 = tile_position + Vector2(sin(number / explosion_accuracy) * explosion_size, cos(number / explosion_accuracy) * explosion_size)
			var tile_type: Vector2i = map.get_cell_atlas_coords(tile)
			
			if tile_type.y == 0:
				map.set_cell(tile, 0, tile_type + Vector2i(0, 1))
