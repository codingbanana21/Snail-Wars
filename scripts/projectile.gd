class_name Projectile
extends CharacterBody2D

@onready var detect_box: Area2D = $DetectBox
@onready var explosion_timer: Timer = $ExplosionTimer

@export var speed: float = 60.0
@export var projectile_gravity: int = 500
@export var damage: float = 45
@export var knockback: int = 1000
@export var explosion_time: float = 2.9
@export var explosion_size: int = 14
@export var explosion_accuracy: float = 20
@export var projectile_hp: int = 1
@export var bounce: bool = false
@export var spawn_at_mouse: bool = false


func _ready() -> void:
	explosion_timer.start(explosion_time)
	
	#spawn type
	if spawn_at_mouse:
		global_position.x = Mouse.global_position.x
		global_position.y = -1024.0
	else:
		global_position += transform.x * 20.0
		velocity += transform.x * speed


func _physics_process(delta: float) -> void:
	velocity.y += projectile_gravity * delta
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
	
	Mouse.shake(damage / 10.0)
	
	var hit_particle: GPUParticles2D = load("res://scenes/hit_particle.tscn").instantiate()
	hit_particle.global_position = global_position
	hit_particle.emitting = true
	hit_particle.amount = int(damage)
	get_parent().add_child(hit_particle)
	
	# destroy map
	var tile_position: Vector2 = round(global_position / 4.0)
	for size in range(explosion_size):
		for number in range(explosion_accuracy * PI * 2):
			get_parent().remove_tile(tile_position + Vector2(sin(number / explosion_accuracy) * size, cos(number / explosion_accuracy) * size))
	
	# hit players
	for player: Player in get_tree().get_nodes_in_group("Player"):
		var dis_to: float = global_position.distance_to(player.global_position)
		
		if dis_to < (4.0 * explosion_size):
			var hit_power: float = clampf(16.0 / dis_to, 0.01, 1.0)
			
			player.damage(hit_power * damage)
			player.velocity = -transform.x * hit_power * knockback


func _on_explosion_timer_timeout() -> void:
	explode(true)


func _on_detect_box_body_entered(body: Node2D) -> void:
	explode()
