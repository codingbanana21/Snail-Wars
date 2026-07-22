class_name Mouse
extends Node2D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	global_position = Globals.mouse_position
