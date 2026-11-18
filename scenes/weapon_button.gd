class_name WeaponButton
extends Button

signal change_weapon(weapon)

@export var weapon: int


func _ready() -> void:
	if ResourceLoader.exists("res://assets/images/"+Globals.WEAPONS.keys()[weapon]+".png"):
		icon = load("res://assets/images/"+Globals.WEAPONS.keys()[weapon]+".png")


func _process(_delta: float) -> void:
	if Globals.teams_weapons and Globals.teams_weapons[Globals.turn.x][weapon] == 0:
		hide()
	else:
		show()


func _on_pressed() -> void:
	emit_signal("change_weapon", weapon)
