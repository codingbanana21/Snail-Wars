class_name Player
extends CharacterBody2D

@onready var snail: Sprite2D = $Snail
@onready var name_label: Label = $NameLabel
@onready var team_label: Label = $TeamLabel
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var next_player_timer: Timer = $NextPlayerTimer

@export var player_number: int = 1
@export var player_name: String
@export var team: String
@export var team_color: Color

const JUMP: float = -400.0
const SPEED: float = 12.0
const JUMP_SPEED: float = 200
const PLAYER_GRAVITY: float = 32.0

var projectile_speed: float = 0.0
var max_hp: int = 100
var hp: int = max_hp
var weapon: int = 1
var dead: bool = false
var dir: float


func _ready() -> void:
	name_label.text = player_name
	team_label.text = "Team " + team
	progress_bar.modulate = team_color


func _process(delta: float) -> void:
	if dead:
		if Globals.player_turn == player_number:
			Globals.next_player()
	else:
		progress_bar.max_value = max_hp
		progress_bar.value = hp
		
		if hp <= 0 or global_position.y > 200:
			dead = true
			global_position.x = 100000
		
		if velocity.x < 0:
			snail.flip_h = true
		elif velocity.x > 0:
			snail.flip_h = false
		
		if Globals.player_turn == player_number:
			snail.modulate.b = (sin(Engine.get_physics_frames() / 10.0) * 10)
			
			if Input.is_action_just_pressed("next_weapon"):
				weapon += 1
			
			if Input.is_action_just_pressed("last_weapon"):
				weapon -= 1
			
			weapon = clamp(weapon, 1, 3)
			
			if global_position > Globals.mouse_position:
				snail.flip_h = true
			else:
				snail.flip_h = false
			
			if Input.is_action_pressed("attack"):
				projectile_speed += 8.0 * delta
			
			if (Input.is_action_just_released("attack") or projectile_speed >= 10.0) and next_player_timer.is_stopped():
				var projectile: Projectile
				
				if weapon == 2:
					projectile = load("res://projectiles/drill.tscn").instantiate()
				elif weapon == 3:
					projectile = load("res://projectiles/heal.tscn").instantiate()
				elif weapon == 4:
					projectile = load("res://projectiles/super_rocket.tscn").instantiate()
				else:
					projectile = load("res://projectiles/rocket.tscn").instantiate()
				
				projectile.global_position = global_position
				projectile.look_at(Globals.mouse_position)
				projectile.speed *= projectile_speed
				get_parent().add_child(projectile)
				
				projectile_speed = 0.0
				next_player_timer.start()
		else:
			snail.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _physics_process(delta: float) -> void:
	if !dead:
		if Globals.player_turn == player_number:
			if is_on_floor():
				dir = Input.get_axis("left", "right")
				velocity.x += dir * SPEED
				
				if Input.is_action_just_pressed("jump"):
					velocity.x += dir * JUMP_SPEED
					velocity.y = JUMP
			else:
				if Input.is_action_pressed("jump"):
					velocity.x += dir * JUMP_SPEED * delta
		velocity.y += PLAYER_GRAVITY
		
		if velocity.y > 64 and is_on_floor():
			velocity.y *= -1
		
		move_and_slide()
		
		if is_on_floor():
			velocity.x *= 0.8
		else:
			velocity.x *= 0.97


func damage(damge: int):
	hp -= damge
	
	var hit_damge: Label = load("res://scenes/hit_damage.tscn").instantiate()
	hit_damge.text = str(damge)
	add_child(hit_damge)


func _on_next_player_timer_timeout() -> void:
	Globals.next_player()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if velocity.y > 700:
		var fall_damage = int((velocity.y - 600) / 15.0)
		damage(fall_damage)
