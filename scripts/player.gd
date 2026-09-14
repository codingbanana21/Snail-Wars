class_name Player
extends CharacterBody2D

@onready var snail: Sprite2D = $Snail
@onready var name_label: Label = $NameLabel
@onready var team_label: Label = $TeamLabel
@onready var hp_label: Label = $HpLabel
@onready var shot_bar: TextureProgressBar = $ShotBar
@onready var next_player_timer: Timer = $NextPlayerTimer

@export var player_number: int = 0
@export var team_number: int = 0
@export var player_name: String
@export var team: String
@export var team_color: Color

const SPEED: float = 6.0
const JUMP: Vector2 = Vector2(90, -350.0)
const PLAYER_GRAVITY: float = 30.0
const WEAPONS: Array[String] = ["rocket", "grenade", "drill", "bomb", "air_strike", "drill_strike", "tnt", "destroyer_of_games"]

var projectile_speed: float = 0.0
var hp: float = 100.0
var weapon: int = 0
var dir: float = 0
var player_turn_part: int = 0


func _ready() -> void:
	name_label.text = player_name
	name_label.modulate = team_color
	
	team_label.text = "Team " + team
	team_label.modulate = team_color
	
	hp_label.modulate = team_color


func _process(delta: float) -> void:
	if Globals.player_turn != player_number or team_number != Globals.team_turn:
		snail.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
		if velocity.x < 0:
			snail.flip_h = true
		elif velocity.x > 0:
			snail.flip_h = false
		return
	
	# skip dead player
	if hp <= 0 or global_position.y >= 200:
		Globals.next_player(true)
		return
	
	shot_bar.rotation = global_position.angle_to_point(Mouse.global_position)
	shot_bar.value = projectile_speed
	
	if global_position > Mouse.global_position and Mouse.moving:
		snail.flip_h = true
	elif Mouse.moving:
		snail.flip_h = false
	
	snail.modulate.b = sin(Engine.get_physics_frames() / 5.0) * 3.0 + 5.0
	
	if !Input.is_action_pressed("attack"):
		if Input.is_action_just_pressed("next_weapon"):
			weapon += 1
		
		if Input.is_action_just_pressed("last_weapon"):
			weapon -= 1
			if weapon < 0:
				weapon = 7
		
		weapon %= 8
		Mouse.weapon_left = str(Globals.teams_weapons[team_number][weapon])
		Mouse.weapon = weapon
	
	if Globals.teams_weapons[team_number][weapon] != 0 and next_player_timer.is_stopped() and player_turn_part == 1:
		if Input.is_action_pressed("attack"):
			projectile_speed += 8.0 * delta
		
		if Input.is_action_just_released("attack") or projectile_speed >= 12.0:
			shot_projectile("res://projectiles/"+WEAPONS[weapon]+".tscn", global_position)
			
			Globals.teams_weapons[team_number][weapon] -= 1
			projectile_speed = 0.0
			player_turn_part = 2
			Mouse.hide()
			Input.action_release("attack")


func _physics_process(delta: float) -> void:
	if velocity.y > 0:
		velocity.y += PLAYER_GRAVITY * 1.5
	else:
		velocity.y += PLAYER_GRAVITY
	
	if (player_turn_part == 1 or player_turn_part == 3) and !Input.is_action_pressed("attack"):
		if is_on_floor():
			dir = Input.get_axis("left", "right")
			velocity.x += dir * SPEED
			
			if Input.is_action_just_pressed("jump"):
				velocity.x += dir * JUMP.x
				velocity.y = JUMP.y
		else:
			if Input.is_action_pressed("jump"):
				velocity.x += dir * JUMP.x * 2.0 * delta
	
	var temp_velocity: Vector2 = velocity
	move_and_slide()
	
	if player_turn_part != 0:
		Mouse.global_position += velocity * delta
	
	if is_on_floor():
		if temp_velocity.y > 800:
			var fall_damage = (temp_velocity.y - 800) / 40.0
			
			Mouse.shake(fall_damage / 5.0)
			damage(fall_damage)
			velocity.y = temp_velocity.y * -0.45
		velocity.x *= 0.8


func shot_projectile(projectile: NodePath, pos : Vector2):
	var new_projectile: Projectile
	new_projectile = load(projectile).instantiate()
	new_projectile.global_position = pos
	new_projectile.look_at(Mouse.global_position)
	new_projectile.speed *= projectile_speed
	call_deferred("add_child", new_projectile)


func damage(hurt_damage: float):
	hp -= hurt_damage
	hp_label.text = str(roundi(hp))
	
	if player_turn_part != 0:
		player_turn_part = 4
		next_player_timer.start()
	
	var hit_damge: Label = load("res://scenes/hit_damage.tscn").instantiate()
	hit_damge.text = str(roundi(hurt_damage))
	add_child(hit_damge)


func next_player():
	if Globals.player_turn == player_number and team_number == Globals.team_turn:
		player_turn_part = 1
	
	if hp <= 0:
		if is_physics_processing():
			set_physics_process(false)
			global_position.y = 10000
	elif player_turn_part != 0:
		Mouse.global_position = global_position


func _on_next_player_timer_timeout() -> void:
	if Globals.player_turn == player_number and team_number == Globals.team_turn:
		if player_turn_part != 4:
			player_turn_part = 4
			next_player_timer.start(1.0)
		else:
			player_turn_part = 0
			Globals.next_player()
