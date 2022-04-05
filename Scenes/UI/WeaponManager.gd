extends Control

var ALL_WEAPONS_STATS = {} #wszystkie bronki

var weapons = {} #posiadane bronki

var hud
var current_weapon
var current_weapon_slot = "Empty"

func _ready():
	hud = owner.get_node("Slots")
	ALL_WEAPONS_STATS = {
		"Axe" : preload("res://Assets/Loot/Weapons/axe.png"),
		"Blade" : preload("res://Assets/Loot/Weapons/blade.png"),
		"BloodSword" : preload("res://Assets/Loot/Weapons/bloodsword.png"),
		"FireScepter" : preload("res://Assets/Loot/Weapons/firescepter.png"),
		"Fms" : preload("res://Assets/Loot/Weapons/fms.png"),
		"Hammer" : preload("res://Assets/Loot/Weapons/hammer.png"),
		"Katana" : preload("res://Assets/Loot/Weapons/katana.png"),
		"Knife" : preload("res://Assets/Loot/Weapons/knife.png"),
		"Spear" : preload("res://Assets/Loot/Weapons/spear.png")
	}
	weapons = {
		"Slot1" : "Blade",
		"Slot2" : "Empty"
	}

var changing_weapon = false
var unequipped_weapon = false

