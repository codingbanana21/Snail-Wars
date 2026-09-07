class_name Projectile
extends CharacterBody2D

@onready var detect_box: Area2D = $DetectBox
@onready var explosion_timer: Timer = $ExplosionTimer

@export var damage: float = 45
@export var size: int = 14
@export var knockback: int = 1000
@export var speed: float = 60.0
@export var gravity: int = 500
@export var projectile_hp: int = 1
@export var timer: float = 3.0
@export var bounce: bool = false
@export var spawn_at_mouse: bool = false
@export var not_players: bool = false


func _ready() -> void:
	if !not_players:
		explosion_timer.start(timer)
	
	#spawn type
	if spawn_at_mouse:
		global_position.x = Mouse.global_position.x
		global_position.y = -1024.0
	else:
		global_position += transform.x * 12.0
		velocity += transform.x * speed


func _physics_process(delta: float) -> void:
	if !not_players:
		Mouse.global_position = global_position
	
	velocity.y += gravity * delta
	rotation = velocity.angle()
	move_and_slide()


func explode(end_explode: bool = false):
	projectile_hp -= 1
	
	if bounce and !end_explode:
		velocity.y *= -0.8
		velocity.x *= 0.8
		return
	elif projectile_hp <= 0 or end_explode:
		end_explode = true
		queue_free()
		
		if !not_players:
			set_physics_process(false)
			get_parent().next_player_timer.start()
			get_parent().has_shot_projectile = false
			Mouse.global_position = get_parent().global_position
	
	Mouse.shake(damage / 5.0)
	
	var hit_particle: GPUParticles2D = load("res://scenes/hit_particle.tscn").instantiate()
	hit_particle.global_position = global_position
	hit_particle.emitting = true
	hit_particle.amount = int(damage)
	get_parent().add_child(hit_particle)
	
	# destroy map
	var tile_position: Vector2 = round(global_position / 4.0)
	var explosion_accuracy: float = PI * 2
	
	for size in range(size):
		for number in range(explosion_accuracy * 8 * size):
			get_parent().get_parent().remove_tile(tile_position + Vector2(sin(number / explosion_accuracy) * size, cos(number / explosion_accuracy) * size))
	
	# hit players
	for player: Player in get_tree().get_nodes_in_group("Player"):
		var dis_to: float = global_position.distance_to(player.global_position)
		
		if dis_to < (4.0 * size):
			var hit_power: float = clampf(16.0 / dis_to, 0.01, 1.0)
			
			player.damage(hit_power * damage)
			player.velocity = -transform.x * hit_power * knockback


func _on_explosion_timer_timeout() -> void:
	explode(true)


func _on_detect_box_body_entered(body: Node2D) -> void:
	if explosion_timer.time_left <= timer - 0.05:
		explode()
