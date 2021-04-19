extends Node

var all_weapons_script = {
		"Axe" : preload("res://Scenes/Equipment/Weapons/Melee/Axe.gd"),
		"Blade" : preload("res://Scenes/Equipment/Weapons/Melee/Blade.gd"),
		"BloodSword" : preload("res://Scenes/Equipment/Weapons/Melee/BloodSword.gd"),
		"Fire Scepter" :preload("res://Scenes/Equipment/Weapons/Magic/Fire Scepter.gd"),
		"FMS" : preload("res://Scenes/Equipment/Weapons/Melee/FMS.gd"),
		"Hammer" :preload("res://Scenes/Equipment/Weapons/Melee/Hammer.gd"),
		"Katana" : preload("res://Scenes/Equipment/Weapons/Melee/Katana.gd"),
		"Knife" : preload("res://Scenes/Equipment/Weapons/Melee/Knife.gd"),
		"Spear" : preload("res://Scenes/Equipment/Weapons/Melee/Spear.gd"),
	}
var all_weapons = {
	"Weapons": {
		"Blade": {
			"attack": "7.5",
			"spd": "1",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Axe": {
			"attack": "10",
			"spd": "0.5",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Katana": {
			"attack": "25",
			"spd": "0.4",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Knife": {
			"attack": "3",
			"spd": "1.5",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Hammer": {
			"attack": "30",
			"spd": "0.3",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Spear": {
			"attack": "15",
			"spd": "0.75",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Fire Scepter": {
			"attack": "10",
			"spd": "1",
			"knc": "0",
			"range": "magic",
			"effect": "none"
		},
		 "BloodSword": {
			"attack": "20",
			"spd": "0.6",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		}
		,
		 "FMS": {
			"attack": "22",
			"spd": "0.5",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		}
		
	}
}
