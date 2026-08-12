extends Node2D

@onready var weapon_label: Label = $WeaponLabel
@onready var shake_timer: Timer = $ShakeTimer
@onready var camera_2d: Camera2D = $Camera2D

var moving: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	if Globals.weapon_number == 0:
		weapon_label.text = "Rocket"
	elif Globals.weapon_number == 1:
		weapon_label.text = "Grenade"
	elif Globals.weapon_number == 2:
		weapon_label.text = "Drill"
	elif Globals.weapon_number == 3:
		weapon_label.text = "Bomb"
	elif Globals.weapon_number == 4:
		weapon_label.text = "Air Strke"
	elif Globals.weapon_number == 5:
		weapon_label.text = "Drill Strke"
	elif Globals.weapon_number == 6:
		weapon_label.text = "Rock"
	
	weapon_label.text += " " + str(Globals.weapons_left[Globals.weapon_number])
	
	if !shake_timer.is_stopped():
		camera_2d.offset.x = randf_range(-3, 3)
		camera_2d.offset.y = randf_range(-3, 3)
	else:
		camera_2d.offset = Vector2.ZERO
	
	if Input.is_action_just_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	if !Input.is_action_pressed("attack") and event is InputEventMouseMotion:
		global_position = Globals.mouse_position
		moving = true
	else:
		moving = false


func shake():
	shake_timer.start()
