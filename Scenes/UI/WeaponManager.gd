extends Control

var all_weapons = {} #wszystkie bronki

var weapons = {} #posiadane bronki

var hud
var current_weapon
var current_weapon_slot = "Empty"

func _ready():
	hud = owner.get_node("Slots")
	all_weapons = {
		"Axe" : preload("res://Assets/Loot/Weapons/axe.png"),
		"Blade" : preload("res://Assets/Loot/Weapons/blade.png"),
		"BloodSword" : preload("res://Assets/Loot/Weapons/BloodSword.png"),
		"FireScepter" : preload("res://Assets/Loot/Weapons/fire scepter.png"),
		"Fms" : preload("res://Assets/Loot/Weapons/fms.png"),
		"Hammer" : preload("res://Assets/Loot/Weapons/Hammer.png"),
		"Katana" : preload("res://Assets/Loot/Weapons/Katana.png"),
		"Knife" : preload("res://Assets/Loot/Weapons/Knife.png"),
		"Spear" : preload("res://Assets/Loot/Weapons/Spear.png")
	}
	weapons = {
		"Slot1" : "Blade",
		"Slot2" : "Empty"
	}

var changing_weapon = false
var unequipped_weapon = false

