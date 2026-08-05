class_name Projectile
extends CharacterBody2D

@onready var detect_box: Area2D = $DetectBox
@onready var hurt_box: Area2D = $HurtBox
@onready var explosion_timer: Timer = $ExplosionTimer

@export var speed: float = 70.0
@export var projectile_gravity: float = 600.0
@export var damage: int = 50
@export var knockback: int = 800
@export var explosion_time: float = 3.0
@export var explosion_size: int = 12
@export var explosion_accuracy: float = 12
@export var projectile_hp: int = 1


func _ready() -> void:
	global_position += transform.x * 24
	velocity += transform.x * speed
	explosion_timer.start(explosion_time)


func _physics_process(delta: float) -> void:
	velocity.y += projectile_gravity * delta
	rotation = velocity.angle()
	
	move_and_slide()


func explode():
	# Shake the screen
	Mouse.shake()
	
	var hit_particle: GPUParticles2D = load("res://scenes/hit_particle.tscn").instantiate()
	hit_particle.global_position = global_position
	hit_particle.emitting = true
	get_parent().add_child(hit_particle)
	
	# destroy map
	var tile_position: Vector2 = round(global_position / 4.0)
	for size in range(explosion_size):
		for number in range(explosion_accuracy * PI * 2):
			get_parent().remove_tile(tile_position + Vector2(sin(number / explosion_accuracy) * size, cos(number / explosion_accuracy) * size))
	
	# hit players
	global_position -= transform.x * 16
	
	for body: Node2D in hurt_box.get_overlapping_bodies():
		if body is Player:
			var hit_power: float = clampf(1.0 / global_position.distance_squared_to(body.global_position) * 1000.0, 0.01, 1.0)
			body.damage(hit_power * damage)
			body.velocity = -transform.x * hit_power * knockback
	
	projectile_hp -= 1
	if projectile_hp <= 0:
		queue_free()


func _on_explosion_timer_timeout() -> void:
	explode()
	queue_free()


func _on_detect_box_body_entered(body: Node2D) -> void:
	explode()
	
	if body is Player:
		queue_free()
	
