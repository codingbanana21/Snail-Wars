class_name MapButton
extends Button

signal setup_map(map)

@export var map: String = "m1"
@export var map_connect: MainMenu


func _ready() -> void:
	setup_map.connect(map_connect._on_map_button_setup_map)


func _on_pressed() -> void:
	emit_signal("setup_map", map)
