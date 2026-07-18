extends Node2D

var mouse_position: Vector2
var player_turn: int = 1


func _process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
