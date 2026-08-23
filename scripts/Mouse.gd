extends Node2D

@onready var weapon_label: Label = $WeaponLabel
@onready var shake_timer: Timer = $ShakeTimer
@onready var camera_2d: Camera2D = $Camera2D

const WEAPONS: Array[String] = ["Rocket", "Grenade", "Drill", "Bomb", "Air Strike", "Drill Strike", "TNT", "Destroyer Of Games"]

var moving: bool = false
var shake_amount: float = 0.0
var weapon_left: String
var weapon: int


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	weapon_label.text = WEAPONS[weapon]+" "+weapon_left
	
	if !shake_timer.is_stopped():
		camera_2d.offset.x = randf_range(-shake_amount, shake_amount)
		camera_2d.offset.y = randf_range(-shake_amount, shake_amount)
	else:
		camera_2d.offset = Vector2.ZERO
	
	if Input.is_action_just_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	if !Input.is_action_pressed("attack") and event is InputEventMouseMotion:
		global_position += event.relative
		moving = true
	else:
		moving = false


func shake(amount: float = 3.0, time: float = 0.1):
	shake_amount = amount
	shake_timer.start(time)
