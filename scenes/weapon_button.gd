class_name WeaponButton
extends Button

signal change_weapon(weapon)

@export var weapon: int


func _on_pressed() -> void:
	emit_signal("change_weapon", weapon)
