extends Node2D

@onready var weapon_label: Label = $WeaponLabel
@onready var shake_timer: Timer = $ShakeTimer
@onready var camera_2d: Camera2D = $Camera2D

const WEAPONS: Array[String] = ["Rocket Launcher","Grenade","Drill Rocket","Bomb","Air Strike","Drill Strike","TNT","Gun","Teleporta","Pumkin Grenade","Present Strike","Cake TNT","Leaf"]

var moving: bool = false
var can_move: bool = false
var shake_amount: float = 0.0
var weapon_left: int
var weapon: int
var ecs_mode: int = 0


func _process(_delta: float) -> void:
	camera_2d.limit_bottom = Globals.water_level + 64
	
	if weapon_left >= 0:
		weapon_label.text = WEAPONS[weapon]+" "+str(weapon_left)
	else:
		weapon_label.text = WEAPONS[weapon]
	
	if !shake_timer.is_stopped():
		camera_2d.offset.x = randf_range(-shake_amount, shake_amount)
		camera_2d.offset.y = randf_range(-shake_amount, shake_amount)
	else:
		camera_2d.offset = Vector2.ZERO
	
	if Input.is_action_just_pressed("esc"):
		if ecs_mode == 1:
			get_tree().quit()
		else:
			ecs_mode = 1
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			hide()


func _input(event: InputEvent) -> void:
	if !Input.is_action_pressed("attack") and event is InputEventMouseMotion and can_move:
		global_position += event.relative
		moving = true
	else:
		if Input.is_action_just_pressed("mouse_lock"):
			ecs_mode = 0
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			show()
		moving = false


@rpc("any_peer","reliable","call_local")
func shake(amount: float = 3.0, time: float = 0.15):
	shake_amount = amount
	shake_timer.start(time)
