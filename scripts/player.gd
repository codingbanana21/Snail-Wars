class_name Player
extends CharacterBody2D

@onready var snail: Sprite2D = $Snail
@onready var name_label: Label = $NameLabel
@onready var team_label: Label = $TeamLabel
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var next_player_timer: Timer = $NextPlayerTimer

@export var player_number: int = 1
@export var player_name: String
@export var team: String
@export var team_color: Color

const JUMP: float = -400.0
const SPEED: float = 12.0
const JUMP_SPEED: float = 200
const PLAYER_GRAVITY: float = 30.0
const WEAPONS: Array[String] = ["rocket", "grenade", "drill", "bomb", "air_strike", "drill_strike", "destroyer_of_games"]

var projectile_speed: float = 0.0
var max_hp: float = 100.0
var hp: float = max_hp
var weapon: int = 0
var dir: float = 0
var weapons_left: Array[int] = [-1,2,2,1,1,1,0]


func _ready() -> void:
	name_label.text = player_name
	team_label.text = "Team " + team
	progress_bar.modulate = team_color


func _process(delta: float) -> void:
	if global_position.y >= 200:
		damage(1)
	
	progress_bar.max_value = max_hp
	progress_bar.value = hp
	
	if velocity.x < 0:
		snail.flip_h = true
	elif velocity.x > 0:
		snail.flip_h = false
	
	if Globals.player_turn != player_number:
		snail.modulate = Color(1.0, 1.0, 1.0, 1.0)
		return
	
	if hp <= 0:
		next_player_timer.stop()
		Globals.next_player()
	
	snail.modulate.b = sin(Engine.get_physics_frames() / 5.0) * 3.0 + 5.0
	
	if Input.is_action_just_pressed("next_weapon"):
		weapon += 1
	
	if Input.is_action_just_pressed("last_weapon"):
		weapon -= 1
	
	weapon = clamp(weapon, 0, 6)
	Globals.weapon_number = weapon
	Globals.weapons_left = weapons_left
	
	if global_position > Mouse.mouse_position and Mouse.moving:
		snail.flip_h = true
	elif Mouse.moving:
		snail.flip_h = false
	
	if weapons_left[weapon] != 0 and next_player_timer.is_stopped():
		if Input.is_action_pressed("attack"):
			projectile_speed += 8.0 * delta
		
		if Input.is_action_just_released("attack") or projectile_speed >= 10.0:
			shot_projectile("res://projectiles/"+WEAPONS[weapon]+".tscn")
			
			weapons_left[weapon] -= 1
			projectile_speed = 0.0
			Input.action_release("attack")
			next_player_timer.start()


func _physics_process(delta: float) -> void:
	velocity.y += PLAYER_GRAVITY
	
	if velocity.y > 64 and is_on_floor():
		velocity.y *= -1
	
	if Globals.player_turn == player_number and !Input.is_action_pressed("attack"):
		if is_on_floor():
			dir = Input.get_axis("left", "right")
			velocity.x += dir * SPEED
			
			if Input.is_action_just_pressed("jump"):
				velocity.x += dir * JUMP_SPEED
				velocity.y = JUMP
		else:
			if Input.is_action_pressed("jump"):
				velocity.x += dir * JUMP_SPEED * delta
	
	move_and_slide()
	
	if is_on_floor():
		velocity.x *= 0.8
	else:
		velocity.x *= 0.97


func shot_projectile(projectile: NodePath):
	var new_projectile: Projectile
	new_projectile = load(projectile).instantiate()
	new_projectile.global_position = global_position
	new_projectile.look_at(Mouse.mouse_position)
	new_projectile.speed *= projectile_speed
	get_parent().add_child(new_projectile)


func damage(damge: float):
	hp -= damge
	
	var hit_damge: Label = load("res://scenes/hit_damage.tscn").instantiate()
	hit_damge.text = str(int(damge))
	add_child(hit_damge)


func next_player():
	if hp <= 0:
		set_physics_process(false)
		global_position.x = 100000
	elif Globals.player_turn == player_number:
		Mouse.mouse_position = global_position


func _on_next_player_timer_timeout() -> void:
	Globals.next_player()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if velocity.y > 700:
		# Shake the screen
		Mouse.shake()
		
		var fall_damage = (velocity.y - 600) / 25.0
		damage(fall_damage)
		
		velocity.y *= -0.5
		
		if Globals.player_turn == player_number:
			next_player_timer.stop()
			Globals.next_player()
