class_name Player
extends CharacterBody2D

@onready var snail: Sprite2D = $Snail
@onready var name_label: Label = $NameLabel
@onready var team_label: Label = $TeamLabel
@onready var hp_label: Label = $HpLabel
@onready var shot_bar: TextureProgressBar = $ShotBar
@onready var arrow: Sprite2D = $Arrow
@onready var ooff: AudioStreamPlayer = $Ooff
@onready var looser: AudioStreamPlayer = $Looser
@onready var impressive: AudioStreamPlayer = $Impressive
@onready var next_player_timer: Timer = $NextPlayerTimer

@export var player_number: int = 0
@export var team_number: int = 0
@export var team_name: String
@export var team_color: Color

const SPEED: float = 6.0
const JUMP: Vector2 = Vector2(90, -350.0)
const PLAYER_GRAVITY: float = 30.0
const WEAPONS: Array[String] = ["rocket", "grenade", "drill", "bomb", "air_strike", "drill_strike", "tnt", "pumkin_grenade", "destroyer_of_games"]
const NAMES: Array[String] = ["","Good", "Bad", "Cool", "Best", "Dumb", "Not", "Dead", "Red", "Blue", "Green"]

var projectile_speed: float = 0.0
var hp: float = 100.0
var weapon: int = 0
var dir: float = 0
var player_turn_part: int = 0
var dead: bool = false


func _ready() -> void:
	name_label.text = NAMES.pick_random() +" "+ team_name
	name_label.modulate = team_color
	team_label.text = "Team " + team_name
	team_label.modulate = team_color
	hp_label.modulate = team_color
	
	if Globals.players_in_team <= player_number:
		hp = 0


func _process(delta: float) -> void:
	if velocity.x < 0:
		snail.flip_h = true
	elif velocity.x > 0:
		snail.flip_h = false
	
	# skip dead player
	if (dead or global_position.y >= 200) and player_turn_part != 0:
		player_turn_part = 0
		hp = 0
		Globals.next_player(true)
		return
	
	if player_turn_part == 0 or player_turn_part == 4:
		arrow.hide()
		return
	
	if Input.is_action_just_pressed("skip"):
		player_turn_part = 4
		next_player_timer.start(0.5)
	
	arrow.show()
	arrow.position.y = sin(Engine.get_physics_frames() / 5.0) * 3.0 - 16.0
	
	if player_turn_part == 1:
		if Input.is_action_pressed("attack"):
			shot_bar.rotation = global_position.angle_to_point(Mouse.global_position)
			shot_bar.value = projectile_speed
			projectile_speed += 8.0 * delta
		else:
			if global_position > Mouse.global_position and Mouse.moving:
				snail.flip_h = true
			elif Mouse.moving:
				snail.flip_h = false
			
			if Input.is_action_just_pressed("next_weapon"):
				weapon += 1
			
			if Input.is_action_just_pressed("last_weapon"):
				weapon -= 1
				if weapon < 0:
					weapon = 8
			
			weapon %= 9
			Mouse.weapon_left = str(Globals.teams_weapons[team_number][weapon])
			Mouse.weapon = weapon
		
		if (Input.is_action_just_released("attack") or projectile_speed >= 10.0) and Globals.teams_weapons[team_number][weapon] != 0:
			Input.action_release("attack")
			shot_projectile("res://projectiles/"+WEAPONS[weapon]+".tscn", global_position)
			Globals.teams_weapons[team_number][weapon] -= 1
			projectile_speed = 0.0
			shot_bar.value = 0
			player_turn_part = 2
			Mouse.hide()


func _physics_process(delta: float) -> void:
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
	hp_label.text = str(int(hp))
	
	var hit_text: Label = load("res://scenes/hit_text.tscn").instantiate()
	hit_text.text = str(int(hurt_damage))
	add_child(hit_text)
	
	if player_turn_part != 0 and hp < 1:
		impressive.play()
	elif player_turn_part != 0:
		looser.play()
	else:
		ooff.play()
	
	if player_turn_part != 0:
		player_turn_part = 4
		next_player_timer.start(3.0)


func next_player():
	if hp < 1 and !dead:
		dead = true
		shot_projectile("res://projectiles/snail.tscn", global_position)
		set_physics_process(false)
		global_position.y = 10000
	
	if Globals.player_turn == player_number and team_number == Globals.team_turn:
		player_turn_part = 1
		Mouse.global_position = global_position


func _on_next_player_timer_timeout() -> void:
	if player_turn_part != 0:
		if player_turn_part != 4:
			player_turn_part = 4
			next_player_timer.start(1.5)
		else:
			player_turn_part = 0
			Globals.next_player()
