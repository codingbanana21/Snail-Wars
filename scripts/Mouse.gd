extends Node2D

@onready var weapon_image: Sprite2D = $WeaponImage
@onready var weapon_label: Label = $WeaponLabel
@onready var ui: CanvasLayer = $UI
@onready var wind: HScrollBar = %Wind
@onready var wind_label: Label = $UI/WindLabel
@onready var shake_timer: Timer = $ShakeTimer
@onready var camera_2d: Camera2D = $Camera2D

var moving: bool = false
var shake_amount: float = 0.0
var weapon_amount: int
var weapon: int = 0
var mouse_mode: int = 0


func _ready() -> void:
	hide()
	ui.hide()
	
	for x in range(4):
		for y in range(6):
			var new_weapon_button: WeaponButton = load("res://scenes/weapon_button.tscn").instantiate()
			var sprite_weapon: int = y * 4 + x
			
			if sprite_weapon >= len(Globals.WEAPONS):
				continue
			
			new_weapon_button.weapon = sprite_weapon
			new_weapon_button.change_weapon.connect(change_weapon)
			
			if ResourceLoader.exists("res://assets/images/"+Globals.WEAPONS.keys()[sprite_weapon]+".png"):
				new_weapon_button.icon = load("res://assets/images/"+Globals.WEAPONS.keys()[sprite_weapon]+".png")
			
			new_weapon_button.global_position = Vector2(512 + x * 20, 196 + y * 20)
			ui.add_child(new_weapon_button)


func _process(_delta: float) -> void:
	camera_2d.limit_bottom = int(Globals.water_level) + 64
	wind.max_value = Globals.wind_speed
	wind.min_value = -Globals.wind_speed
	
	wind.value = Globals.wind
	wind_label.text = "Wind " + str(Globals.wind)
	
	if weapon_amount >= 0:
		weapon_label.text = Globals.WEAPONS[Globals.WEAPONS.keys()[weapon]][Globals.NAME]+" "+str(weapon_amount)
	else:
		weapon_label.text = Globals.WEAPONS[Globals.WEAPONS.keys()[weapon]][Globals.NAME]
	
	if !shake_timer.is_stopped():
		camera_2d.offset.x = randf_range(-shake_amount, shake_amount)
		camera_2d.offset.y = randf_range(-shake_amount, shake_amount)
	else:
		camera_2d.offset = Vector2.ZERO
	
	if Input.is_action_just_pressed("esc"):
		if mouse_mode == 0:
			get_tree().quit()
		else:
			mouse_mode = 0
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			hide()


func change_weapon(new_weapon: int):
	weapon = new_weapon
	
	if ResourceLoader.exists("res://assets/images/"+Globals.WEAPONS.keys()[weapon]+".png"):
		weapon_image.texture = load("res://assets/images/"+Globals.WEAPONS.keys()[weapon]+".png")
	else:
		weapon_image.texture = load("res://assets/images/rocket.png")


func _input(event: InputEvent) -> void:
	if !Input.is_action_pressed("attack") and event is InputEventMouseMotion:
		moving = true
		global_position += event.relative
	else:
		moving = false
		if Input.is_action_just_pressed("mouse_lock"):
			if mouse_mode != 1:
				mouse_mode = 1
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				show()
			else:
				mouse_mode = 2
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				hide()


@rpc("any_peer","reliable","call_local")
func shake(amount: float = 3.0, time: float = 0.15):
	shake_amount = amount
	shake_timer.start(time)
