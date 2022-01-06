extends Node

var all_weapons_script = {
		"axe" : preload("res://Scenes/Equipment/Weapons/Melee/Axe.gd"),
		"blade" : preload("res://Scenes/Equipment/Weapons/Melee/Blade.gd"),
		"bloodsword" : preload("res://Scenes/Equipment/Weapons/Melee/BloodSword.gd"),
		"fms" : preload("res://Scenes/Equipment/Weapons/Melee/fms.gd"),
		"hammer" :preload("res://Scenes/Equipment/Weapons/Melee/Hammer.gd"),
		"katana" : preload("res://Scenes/Equipment/Weapons/Melee/Katana.gd"),
		"knife" : preload("res://Scenes/Equipment/Weapons/Melee/Knife.gd"),
		"spear" : preload("res://Scenes/Equipment/Weapons/Melee/Spear.gd"),
	}
var all_weapons = {
	"Weapons": {
		"blade": {
			"attack": "12",
			"spd": "1",
			"knc": float(0.15),
			"range": "melee",
			"effect": "none"
		},
		"axe": {
			"attack": "10",
			"spd": "0.5",
			"knc": float(0.5),
			"range": "melee",
			"effect": "none"
		},
		"katana": {
			"attack": "15",
			"spd": "0.4",
			"knc": float(0.1),
			"range": "melee",
			"effect": "none"
		},
		"knife": {
			"attack": "3",
			"spd": "1.5",
			"knc": float(0.0),
			"range": "melee",
			"effect": "none"
		},
		"hammer": {
			"attack": "30",
			"spd": "0.3",
			"knc": float(1.0),
			"range": "melee",
			"effect": "none"
		},
		"spear": {
			"attack": "15",
			"spd": "0.75",
			"knc": float(0.25),
			"range": "melee",
			"effect": "none"
		},
		 "bloodsword": {
			"attack": "20",
			"spd": "0.6",
			"knc": float(0.3),
			"range": "melee",
			"effect": "none"
		}
		,
		 "fms": {
			"attack": "22",
			"spd": "0.5",
			"knc": float(0.5),
			"range": "melee",
			"effect": "none"
		}
		
	}
}

var all_weapons_p = {
		"blade+": {
			"attack": "15",
			"spd": "0.5",
			"knc": float(0.75),
			"range": "melee",
			"effect": "none"
		},
		"axe+": {
			"attack": "15",
			"spd": "0.5",
			"knc": float(0.75),
			"range": "melee",
			"effect": "none"
		},
		"katana+": {
			"attack": "18",
			"spd": "0.8",
			"knc": float(0.1),
			"range": "melee",
			"effect": "none"
		},
		"knife+": {
			"attack": "5",
			"spd": "1.5",
			"knc": float(0),
			"range": "melee",
			"effect": "none"
		},
		"hammer+": {
			"attack": "30",
			"spd": "0.3",
			"knc": float(3),
			"range": "melee",
			"effect": "none"
		},
		"spear+": {
			"attack": "15",
			"spd": "1",
			"knc": float(0.25),
			"range": "melee",
			"effect": "none"
		},
		"fire Scepter+": {
			"attack": "13",
			"spd": "1",
			"knc": float(0.75),
			"range": "magic",
			"effect": "none"
		},
		"bloodSword+": {
			"attack": "20",
			"spd": "1",
			"knc": float(0.3),
			"range": "melee",
			"effect": "none"
		},
		"fms+": {
			"attack": "22",
			"spd": "1",
			"knc": float(0.5),
			"range": "melee",
			"effect": "none"
		}
		
}
