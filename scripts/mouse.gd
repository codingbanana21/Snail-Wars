extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var shake_timer: Timer = $ShakeTimer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	if !shake_timer.is_stopped():
		camera_2d.offset.x = randf_range(-3, 3)
		camera_2d.offset.y = randf_range(-3, 3)
	else:
		camera_2d.offset = Vector2.ZERO
	
	if Input.is_action_just_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	global_position = Globals.mouse_position


func shake():
	shake_timer.start()
