extends StaticBody2D

var WeaponName
var Stats = {}
var popups = {}
var weapons = {}


func _ready():
	#Pobiera wszystkie statystyki broni i zostawia sobie statystyki dla odpowiedniej broni

	weapons = {
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
} #Pobiera dane z pliku
	Stats = weapons["Weapons"][WeaponName]
	Stats['attack'] = float(Stats['attack'])
	var texture = load("res://Assets/Loot/Weapons/"+WeaponName+".png")
	$Sprite.texture = texture
	if (WeaponName == null):
		queue_free()
#test
func take_dmg(a):
	pass

func _on_PopUp_body_entered(body):
	 #Przypisuje zmienne i tworzy okienko statystyk broni
	if body.name == "Player":
		var popup = load("res://Scenes/UI/ItemStats.tscn")
		popup = popup.instance()
		popup.itemName = WeaponName
		popup.itemAttack = Stats['attack']
		popup.itemSpd = Stats['spd']
		popup.itemKnc = Stats['knc']
		popup.rect_scale.x = 0.3
		popup.rect_scale.y = 0.3
		add_child(popup)
		popups[body] = popup
		
func _on_PopUp_body_exited(body):
	if body in popups:
		popups[body].queue_free()
