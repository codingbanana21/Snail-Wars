class_name Projectile
extends Area2D

@onready var hit_area: Area2D = $HitArea

@export var damage: int = 60
@export var knockback: int = 1000
@export var explosion_size: int = 3
@export var explosion_accuracy: float = 3
@export var hp: int = 1

var velocity: Vector2 = Vector2.ZERO
var speed: float

func _ready() -> void:
	global_position += transform.x * 24


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	global_position += velocity * delta
	global_position += transform.x * speed * delta
	
	var hit: bool = false
	
	for body: Node2D in self.get_overlapping_bodies():
		hit = true
		if body is Player:
			queue_free()
	
	if hit:
		var hit_particle: GPUParticles2D = load("res://scenes/hit_particle.tscn").instantiate()
		hit_particle.global_position = global_position
		hit_particle.emitting = true
		get_parent().add_child(hit_particle)
		
		# destroy map
		var tile_position: Vector2 = round(global_position / 16.0)
		
		for size in range(explosion_size):
			for number in range(explosion_accuracy * PI * 2):
				get_parent().remove_tile(tile_position + Vector2(sin(number / explosion_accuracy) * size, cos(number / explosion_accuracy) * size))
		
		# hit players
		global_position -= transform.x * speed * delta
		for body: Node2D in hit_area.get_overlapping_bodies():
			if body is Player:
				var hit_power: float = clampf(1.0 / global_position.distance_squared_to(body.global_position) * 1000.0, 0.0001, 1.0)
				body.hp -= hit_power * damage
				body.velocity = -transform.x * hit_power * knockback
		
		hp -= 1
		if hp <= 0:
			queue_free()


func _on_die_timer_timeout() -> void:
	queue_free()
