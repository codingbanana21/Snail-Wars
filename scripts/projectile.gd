class_name Projectile
extends CharacterBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var detect_box: Area2D = $DetectBox
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var explosion_timer: Timer = $ExplosionTimer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var hit_timer: Timer = $HitTimer

#projectile states
@export_group("Hit")
@export var damage: int = 45
@export var size: int = 5
@export var knockback: int = 40
@export var projectile_hp: int = 1
@export var hit_stun_time: float = 0.0

@export_group("Movement")
@export var speed: int = 60
@export var min_speed: int = 60
@export var gravity: int = 400
@export var bounce: bool = false
@export var spawn_at_mouse: bool = false
@export var effect_by_wind: bool = true
@export var spawn_offset: int = 16

@export_group("Other")
@export var timer: float = 3.0
@export var flag_number: int = -1
@export var particles: bool = true
@export var camera_follow: bool = true

@export_group("Player")
@export var end_player_turn: bool = true
@export var bomb_sound: bool = true
@export var teleports_player: bool = false
@export var life_steal: int = 0
@export var spawn_time: float = 0.0
@export var spawns: Array[String]

var id: int
var parent: Player
var bodies_needed: int = 1


func _enter_tree() -> void:
	set_multiplayer_authority(id)


func _ready() -> void:
	if min_speed > speed: speed = min_speed
	
	#spawn type normal or strike
	if spawn_at_mouse:
		global_position = Vector2(Mouse.global_position.x, -2148.0)
		velocity.y += speed
	else:
		global_position += transform.x * spawn_offset
		velocity += transform.x * speed
	
	#settings setup
	if get_parent() as Player: parent = get_parent()
	if camera_follow: Mouse.global_position = global_position
	if spawn_time > 0: spawn_timer.start(spawn_time)
	if timer > 0: explosion_timer.start(timer)
	if collision_shape_2d.shape != null: bodies_needed = 2
	
	if Globals.high_graphics and particles:
		gpu_particles_2d.show()


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	if global_position.y >= Globals.water_level:
		explode.rpc(true)
		return
	elif len(detect_box.get_overlapping_bodies()) + len(detect_box.get_overlapping_areas()) >= bodies_needed:
		explode.rpc()
	
	if !hit_timer.is_stopped(): return
	
	velocity.y += gravity * delta
	if effect_by_wind and !is_on_floor():
		velocity.x += Globals.wind * 16 * delta
	
	rotation = velocity.angle()
	
	var temp_velocity: Vector2 = velocity
	move_and_slide()
	
	if bounce:
		if is_on_floor():
			velocity.x = temp_velocity.x * 0.95
			velocity.y = temp_velocity.y * -0.6
		
		if is_on_wall():
			velocity.x = temp_velocity.x * -0.6
			velocity.y = temp_velocity.y * 0.95
	
	if camera_follow: Mouse.global_position += velocity * delta

@rpc("any_peer","call_local","reliable")
func explode(end_explode: bool = false):
	if !hit_timer.is_stopped(): return
	
	if bomb_sound: parent.bomb.play()
	
	if Globals.high_graphics and particles and damage > 0:
		var hit_particle: GPUParticles2D = load("res://scenes/hit_particle.tscn").instantiate()
		hit_particle.global_position = global_position
		hit_particle.emitting = true
		hit_particle.amount = clampi(int(damage), 1, 100)
		parent.add_child(hit_particle)
	
	if !is_multiplayer_authority(): return
	
	if hit_stun_time > 0:
		hit_timer.start(hit_stun_time)
	
	projectile_hp -= 1
	
	if Globals.high_graphics: Mouse.shake.rpc(damage / 4.0)
	
	if len(spawns) > 0:
		parent.multiplayer_spawner.spawn({
			"id": id,
			"global_position": global_position,
			"projectile_speed":0,
			"mouse_position":Mouse.global_position,
			"projectile": "res://projectiles/" + spawns.pick_random() + ".tscn"
		})
	
	if projectile_hp == 0 or end_explode:
		end_explode = true
		queue_free()
		
		#if the projectile is a players end player turn
		if end_player_turn and parent.player_turn_part != Globals.TurnState.IDLE:
			parent.next_player_timer.start()
			parent.player_turn_part = Globals.TurnState.RESOLVING
			Mouse.global_position = parent.global_position
	
	#get map and explode it
	for map in get_tree().get_nodes_in_group("Map"):
		map.explode_tile.rpc(global_position, size * Globals.explosion_power)
	
	#hit players
	for player: Player in get_tree().get_nodes_in_group("Player"):
		var dis_to: float = global_position.distance_to(player.global_position)
		if dis_to < (8.0 * size * Globals.explosion_power) + 8.0:
			var hit_power: float = clampf(16.0 / dis_to, 0.01, 1.0) * Globals.explosion_power
			player.hit.rpc(int(damage * hit_power), (player.global_position - global_position) * hit_power * knockback)
			
			if life_steal > 0:
				parent.heal.rpc(int(life_steal * hit_power))
	
	if flag_number != -1:
		for player: Player in get_tree().get_nodes_in_group("Player"):
			if player.team_number == flag_number:
				player.die.rpc(true)
	
	if teleports_player: parent.teleport.rpc(global_position)


func _on_explosion_timer_timeout() -> void:
	if !is_multiplayer_authority(): return
	explode.rpc(true)


func _on_spawn_timer_timeout() -> void:
	if len(spawns) > 0 and is_multiplayer_authority():
		parent.multiplayer_spawner.spawn({
			"id": id,
			"global_position": global_position,
			"projectile_speed":0,
			"mouse_position":Mouse.global_position,
			"projectile": "res://projectiles/" + spawns.pick_random() + ".tscn"
		})
