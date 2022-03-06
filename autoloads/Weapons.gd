extends Node

var all_weapons_scenes = {
	"Axe" : preload("res://Scenes/Equipment/Weapons/Melee/Axe.gd"),
	"Blade" : preload("res://Scenes/Equipment/Weapons/Melee/blade/Blade.tscn"),
	"Bloodsword" : preload("res://Scenes/Equipment/Weapons/Melee/BloodSword.gd"),
	"FMS" : preload("res://Scenes/Equipment/Weapons/Melee/FMS.gd"),
	"Hammer" :preload("res://Scenes/Equipment/Weapons/Melee/Hammer.gd"),
	"Katana" : preload("res://Scenes/Equipment/Weapons/Melee/Katana.gd"),
	"Knife" : preload("res://Scenes/Equipment/Weapons/Melee/Knife.gd"),
	"Spear" : preload("res://Scenes/Equipment/Weapons/Melee/Spear.gd"),
}
var all_weapons_textures = {
	"Axe" : preload("res://Assets/Loot/Weapons/axe.png"),
	"Blade" : preload("res://Assets/Loot/Weapons/blade.png"),
	"BloodSword" : preload("res://Assets/Loot/Weapons/BloodSword.png"),
	"Fire Scepter" : preload("res://Assets/Loot/Weapons/firescepter.png"),
	"FMS" : preload("res://Assets/Loot/Weapons/FMS.png"),
	"Hammer" : preload("res://Assets/Loot/Weapons/hammer.png"),
	"Katana" : preload("res://Assets/Loot/Weapons/katana.png"),
	"Knife" : preload("res://Assets/Loot/Weapons/knife.png"),
	"Spear" : preload("res://Assets/Loot/Weapons/spear.png"),
}
var all_weapons = {
	"Blade": {
		"attack": "12",
		"spd": "1",
		"knc": float(0.15),
		"range": "melee",
		"effect": "none"
	},
	"Axe": {
		"attack": "10",
		"spd": "0.5",
		"knc": float(0.75),
		"range": "melee",
		"effect": "none"
	},
	"Katana": {
		"attack": "15",
		"spd": "0.4",
		"knc": float(0.1),
		"range": "melee",
		"effect": "none"
	},
	"Knife": {
		"attack": "3",
		"spd": "1.5",
		"knc": float(0.0),
		"range": "melee",
		"effect": "none"
	},
	"Hammer": {
		"attack": "30",
		"spd": "0.3",
		"knc": float(1.0),
		"range": "melee",
		"effect": "none"
	},
	"Spear": {
		"attack": "15",
		"spd": "0.75",
		"knc": float(0.25),
		"range": "melee",
		"effect": "none"
	},
	 "BloodSword": {
		"attack": "20",
		"spd": "0.6",
		"knc": float(0.3),
		"range": "melee",
		"effect": "none"
	},
	 "FMS": {
		"attack": "22",
		"spd": "0.5",
		"knc": float(0.5),
		"range": "melee",
		"effect": "none"
	}
}
