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

const JUMP: float = -400.0
const SPEED: float = 10.0
const JUMP_SPEED: float = 100
const PLAYER_GRAVITY: float = 30.0
const WEAPONS: Array[String] = ["rocket", "grenade", "drill", "bomb", "air_strike", "drill_strike", "tnt", "destroyer_of_games"]

var projectile_speed: float = 0.0
var hp: float = 100.0
var weapon: int = 0
var dir: float = 0
var has_shot_projectile: bool = false
var is_player_turn: bool


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
	
	if Globals.teams_weapons[team_number][weapon] != 0 and next_player_timer.is_stopped() and !has_shot_projectile:
		if Input.is_action_pressed("attack"):
			projectile_speed += 8.0 * delta
		
		if Input.is_action_just_released("attack") or projectile_speed >= 12.0:
			shot_projectile("res://projectiles/"+WEAPONS[weapon]+".tscn", global_position)
			
			Globals.teams_weapons[team_number][weapon] -= 1
			projectile_speed = 0.0
			has_shot_projectile = true
			Mouse.hide()
			Input.action_release("attack")


func _physics_process(delta: float) -> void:
	if velocity.y > 0:
		velocity.y += PLAYER_GRAVITY * 1.5
	else:
		velocity.y += PLAYER_GRAVITY
	
	if is_player_turn and !has_shot_projectile and !Input.is_action_pressed("attack"):
		if is_on_floor():
			dir = Input.get_axis("left", "right")
			velocity.x += dir * SPEED
			
			if Input.is_action_just_pressed("jump"):
				velocity.x += dir * JUMP_SPEED
				velocity.y = JUMP
		else:
			if Input.is_action_pressed("jump"):
				velocity.x += dir * JUMP_SPEED * 2.0 * delta
	
	var temp_velocity: Vector2 = velocity
	move_and_slide()
	
	if is_player_turn:
		Mouse.global_position += velocity * delta
	
	if is_on_floor():
		if temp_velocity.y > 800:
			var fall_damage = (temp_velocity.y - 800) / 40.0
			
			Mouse.shake(fall_damage / 5.0)
			damage(fall_damage)
			velocity.y = temp_velocity.y * -0.5
		velocity.x *= 0.7
	else:
		velocity.x *= 0.97


func shot_projectile(projectile: NodePath, pos : Vector2):
	var new_projectile: Projectile
	new_projectile = load(projectile).instantiate()
	new_projectile.global_position = pos
	new_projectile.look_at(Mouse.global_position)
	new_projectile.speed *= projectile_speed
	add_child(new_projectile)


func damage(hurt_damage: float):
	hp -= hurt_damage
	hp_label.text = str(roundi(hp))
	
	if is_player_turn:
		next_player_timer.start()
		has_shot_projectile = true
	
	var hit_damge: Label = load("res://scenes/hit_damage.tscn").instantiate()
	hit_damge.text = str(roundi(hurt_damage))
	add_child(hit_damge)


func next_player():
	is_player_turn = Globals.player_turn == player_number and team_number == Globals.team_turn
	
	if hp <= 0:
		if is_physics_processing():
			set_physics_process(false)
			global_position.y = 10000
	elif is_player_turn:
		Mouse.global_position = global_position


func _on_next_player_timer_timeout() -> void:
	if Globals.player_turn == player_number and team_number == Globals.team_turn:
		has_shot_projectile = false
		Globals.next_player()
