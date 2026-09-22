class_name Projectile
extends CharacterBody2D

@onready var detect_box: Area2D = $DetectBox
@onready var explosion_timer: Timer = $ExplosionTimer
@onready var hit_timer: Timer = $HitTimer

@export var damage: int = 45
@export var size: int = 8
@export var knockback: int = 800
@export var speed: int = 60
@export var gravity: int = 500
@export var projectile_hp: int = 1
@export var hit_stun_time: float = 0.05
@export var timer: float = 3.0
@export var bounce: bool = false
@export var spawn_at_mouse: bool = false
@export var not_players: bool = false
@export var spawn: bool = false
@export var spawn_type: String = "fragment"


func _ready() -> void:
	if timer > 0:
		explosion_timer.start(timer)
	
	#spawn type
	if spawn_at_mouse:
		global_position.x = Mouse.global_position.x
		global_position.y = -1040.0
		velocity.y += speed
	else:
		global_position += transform.x * 16.0
		velocity += transform.x * speed


func _physics_process(delta: float) -> void:
	if global_position.y >= 200:
		explode(true)
		return
	
	if len(detect_box.get_overlapping_bodies()) > 0:
		explode()
	
	if !hit_timer.is_stopped():
		return
	
	if !not_players:
		Mouse.global_position = global_position
	
	velocity.y += gravity * delta
	rotation = velocity.angle()
	
	var temp_velocity: Vector2 = velocity
	move_and_slide()
	
	if is_on_floor() and bounce:
		velocity.x = temp_velocity.x * 0.95
		velocity.y = temp_velocity.y * -0.65
	
	if is_on_wall() and bounce:
		velocity.x = temp_velocity.x * -0.65
		velocity.y = temp_velocity.y * 0.95


func explode(end_explode: bool = false):
	projectile_hp -= 1
	hit_timer.start(hit_stun_time)
	Mouse.shake(damage / 5.0)
	
	var hit_particle: GPUParticles2D = load("res://scenes/hit_particle.tscn").instantiate()
	hit_particle.global_position = global_position
	hit_particle.emitting = true
	hit_particle.amount = clampi(int(damage), 1, 200)
	get_parent().add_child(hit_particle)
	
	if spawn:
		get_parent().shot_projectile("res://projectiles/"+spawn_type+".tscn", global_position)
	
	if projectile_hp == 0 or end_explode:
		end_explode = true
		queue_free()
		
		if !not_players:
			set_physics_process(false)
			get_parent().next_player_timer.start()
			get_parent().player_turn_part = 3
			Mouse.global_position = get_parent().global_position
	
	# destroy map
	get_tree().current_scene.explode_tile(global_position, size)
	
	# hit players
	for player: Player in get_tree().get_nodes_in_group("Player"):
		var dis_to: float = global_position.distance_to(player.global_position)
		if dis_to < (4.0 * size):
			var hit_power: float = clampf(16.0 / dis_to, 0.01, 1.0)
			player.damage(int(hit_power * damage))
			player.velocity = -transform.x * hit_power * knockback


func _on_explosion_timer_timeout() -> void:
	explode(true)
