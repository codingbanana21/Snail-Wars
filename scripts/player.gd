class_name Player
extends CharacterBody2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var snail: Sprite2D = $Snail
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var name_label: Label = $NameLabel
@onready var team_label: Label = $TeamLabel
@onready var hp_label: Label = $HpLabel
@onready var shot_bar: TextureProgressBar = $ShotBar
@onready var turn_arrow: Sprite2D = $TurnArrow
@onready var next_player_timer: Timer = $NextPlayerTimer

#sound effects
@onready var ooff: AudioStreamPlayer = $Ooff
@onready var ooff_2: AudioStreamPlayer = $Ooff2
@onready var loser: AudioStreamPlayer = $Loser
@onready var stupid: AudioStreamPlayer = $Stupid
@onready var impressive: AudioStreamPlayer = $Impressive
@onready var wast_of_time: AudioStreamPlayer = $WastOfTime
@onready var bomb: AudioStreamPlayer = $Bomb

enum TurnState {IDLE, AIMING, FIRED, RESOLVING, ENDING}

const SPEED: float = 240.0
const JUMP: Vector2 = Vector2(150.0, -300.0)
const BACK_JUMP: Vector2 = Vector2(-60.0, -400.0)
const PLAYER_GRAVITY: float = 1800.0
const NAMES: Array[String] = ["Barry","Bob","Jim","Dave","Rick","Rob","Ray","Nick","Leo","Steve"]
const NAMES2: Array[String] = ["Good","Bad","Cool","Best","Dumb","Not","Dead","Same","Super","The","Just","I am"]

var id: int
var rng = RandomNumberGenerator.new()

var player_number: int = 0
var team_number: int = 0
var hp: int = 100
var projectile_speed: float = 0.0
var weapon_number: int = 0
var dir: float = 0
var player_turn_part: int = TurnState.IDLE
var dead: bool = false
var team_color: Color


func _enter_tree() -> void:
	set_multiplayer_authority(id)
	#player rng for random names
	rng.seed = player_number + (team_number * 10)


func _ready() -> void:
	multiplayer_spawner.spawn_function = shot_projectile
	hp = Globals.player_hp
	hp_label.text = str(hp)
	name_label.text = NAMES2[rng.randi_range(0, NAMES2.size() - 1)] +" "+ NAMES[rng.randi_range(0, NAMES.size() - 1)]
	name_label.modulate = team_color
	team_label.text = "Team "+str(team_number)
	team_label.modulate = team_color
	hp_label.modulate = team_color


func _process(delta: float) -> void:
	if !is_multiplayer_authority() or dead: return
	
	if hp < 1:
		die.rpc(true)
	
	if global_position.y >= Globals.water_level:
		die.rpc(false)
		return
	
	if player_turn_part == TurnState.IDLE or player_turn_part == TurnState.ENDING:
		turn_arrow.hide()
		return
	
	turn_arrow.show()
	turn_arrow.position.y = sin(Engine.get_physics_frames() / 5.0) * 3.0 - 16.0
	
	if (global_position.x > Cursor.global_position.x and Cursor.moving) or velocity.x < 0:
		snail.flip_h = true
	elif Cursor.moving or velocity.x > 0:
		snail.flip_h = false
	
	if Input.is_action_just_pressed("skip"):
		player_turn_part = TurnState.ENDING
		next_player_timer.start(0.1)
	
	weapon_number = Cursor.weapon_number
	Cursor.weapon_amount = Globals.teams_weapons[team_number][weapon_number]
	
	if player_turn_part == TurnState.AIMING and Globals.teams_weapons[team_number][weapon_number] != 0 and Cursor.mouse_mode == 1:
		if Input.is_action_pressed("attack"):
			shot_bar.rotation = global_position.angle_to_point(Cursor.global_position)
			shot_bar.value = projectile_speed
			projectile_speed += 8.0 * delta
		
		if (Input.is_action_just_released("attack") or projectile_speed >= 10.0):
			var scene: PackedScene = load("res://projectiles/" + Globals.WEAPONS.keys()[weapon_number] + ".tscn")
			var new_projectile: Projectile = scene.instantiate()
			
			for i in range(new_projectile.spawn_amount):
				multiplayer_spawner.spawn({
					"id": id,
					"global_position": global_position,
					"offset": Vector2(i * 24.0, 0),
					"projectile_speed": projectile_speed,
					"mouse_position": Cursor.global_position,
					"projectile": "res://projectiles/" + Globals.WEAPONS.keys()[weapon_number] + ".tscn"
				})
			new_projectile.free()
			Input.action_release("attack")
			Globals.teams_weapons[team_number][weapon_number] -= 1
			projectile_speed = 0.0
			shot_bar.value = 0


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	if velocity.y <= 2500.0:
		velocity.y += PLAYER_GRAVITY * Globals.gravity * delta
	
	if player_turn_part != TurnState.IDLE and player_turn_part != TurnState.ENDING and !Input.is_action_pressed("attack"):
		if is_on_floor():
			dir = Input.get_axis("left", "right")
			velocity.x += dir * SPEED * delta
			
			if Input.is_action_just_pressed("jump"):
				velocity = Vector2(dir * JUMP.x, JUMP.y)
			elif Input.is_action_just_pressed("back_jump"):
				velocity = Vector2(dir * BACK_JUMP.x, BACK_JUMP.y)
		else:
			if Input.is_action_pressed("jump"):
				velocity.x += dir * JUMP.x * delta
			elif Input.is_action_pressed("back_jump"):
				velocity.x += dir * BACK_JUMP.x * delta
	
	var temp_velocity: Vector2 = velocity
	move_and_slide()
	
	if player_turn_part != TurnState.IDLE:
		Cursor.global_position += velocity * delta
	
	if is_on_floor():
		if temp_velocity.y >= 750:
			var fall_damage: int = -int((temp_velocity.y - 750) / 50.0)
			hit.rpc(fall_damage)
			
			if Globals.high_graphics:
				Cursor.shake.rpc(fall_damage / 5.0)
		velocity.x *= 0.75
	else:
		velocity.x *= 0.98


func shot_projectile(inputs: Dictionary = {"id":1,
		"global_position":Vector2.ZERO,
		"offset": Vector2.ZERO,
		"projectile_speed":0,
		"mouse_position":Vector2.ZERO,
		"projectile":"res://projectiles/rocket.tscn"
		}):
	
	var scene: PackedScene = load(inputs["projectile"])
	var new_projectile: Projectile = scene.instantiate()
	
	new_projectile.id = inputs["id"]
	
	if new_projectile.spawn_at_mouse:
		new_projectile.global_position = Cursor.global_position + Vector2(0.0, -1024.0) + inputs["offset"]
		new_projectile.rotation = PI * 0.5
	else:
		new_projectile.global_position = inputs["global_position"]
		new_projectile.look_at(inputs["mouse_position"])
	
	new_projectile.speed *= inputs["projectile_speed"]
	
	if new_projectile.end_player_turn:
		player_turn_part = TurnState.FIRED
		Cursor.hide()
	
	return new_projectile


@rpc("any_peer","reliable","call_local")
func hit(hp_change: int = 0, knockback: Vector2 = Vector2.ZERO):
	hp += hp_change
	velocity += knockback
	hp_label.text = str(hp)
	var hit_text: Label
	
	if hp_change != 0:
		hit_text = load("res://scenes/hit_text.tscn").instantiate()
		
		if hp_change < 0:
			hit_text.text = str(-hp_change)
		else:
			hit_text.text = "+" + str(hp_change)
		add_child(hit_text)
	
	if hp_change < 0:
		if player_turn_part != TurnState.IDLE and hp > 0:
			if rng.randf() >= 0.5:
				loser.play()
			else:
				stupid.play()
		else:
			if rng.randf() >= 0.5:
				ooff.pitch_scale = randf_range(1.65, 1.75)
				ooff.play()
			else:
				ooff_2.pitch_scale = randf_range(1.75, 1.85)
				ooff_2.play()
		
		if player_turn_part != TurnState.IDLE and is_multiplayer_authority():
			Cursor.hide()
			player_turn_part = TurnState.ENDING
			next_player_timer.start(1.0)


@rpc("any_peer","call_local","reliable")
func die(spawn: bool = false):
	if spawn and is_multiplayer_authority():
		multiplayer_spawner.spawn({
			"id": id,
			"global_position": global_position,
			"offset": Vector2.ZERO,
			"projectile_speed":projectile_speed,
			"mouse_position":Cursor.global_position,
			"projectile": "res://projectiles/snail.tscn"
		})
	
	Globals.alive_players[team_number][player_number] = false
	
	if player_turn_part != TurnState.IDLE:
		if player_turn_part == TurnState.AIMING:
			wast_of_time.play()
		else:
			impressive.play()
		Globals.next_player.rpc()
	
	player_turn_part = TurnState.IDLE
	dead = true
	set_physics_process(false)
	collision_shape_2d.disabled = true
	global_position.y = -10000.0


@rpc("any_peer", "call_local", "reliable")
func teleport(teleport_position):
	global_position = teleport_position
	velocity = Vector2.ZERO


@rpc("any_peer", "call_local", "reliable")
func next_player(turn: Vector2i):
	#remove particles
	for child: Node in get_children():
		if child is GPUParticles2D:
			child.queue_free()
	
	if turn.x == team_number and turn.y == player_number:
		player_turn_part = TurnState.AIMING
		Cursor.global_position = global_position
	else:
		player_turn_part = TurnState.IDLE


func _on_next_player_timer_timeout() -> void:
	if player_turn_part != TurnState.IDLE:
		if player_turn_part != TurnState.ENDING:
			player_turn_part = TurnState.ENDING
			next_player_timer.start(1.0)
		else:
			player_turn_part = TurnState.IDLE
			Globals.next_player.rpc()
