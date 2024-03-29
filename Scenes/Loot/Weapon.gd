extends StaticBody2D

var weaponName
var Stats = {}
var popups = {}
var weapons = {}
var texture = null
onready var ALL_WEAPONS_STATS = Weapons.ALL_WEAPONS_STATS #Wczytanie z niewidzialnego node wszystkich broni

func _ready():
	Stats = ALL_WEAPONS_STATS[weaponName]
	Stats['attack'] = float(Stats['attack'])
	texture = load("res://Assets/Loot/Weapons/"+weaponName+".png")
	if weaponName == "Katana":
		$Sprite.scale.x = .5
		$Sprite.scale.y = .5
	elif weaponName == "Spear":
		$Sprite.scale.x = .8
		$Sprite.scale.y = .8
	else:
		$Sprite.scale.x = 1
		$Sprite.scale.y = 1
	$Sprite.texture = texture
	if (weaponName == null):
		queue_free()
#test
func take_dmg(_a):
	pass
func _on_PopUp_body_entered(body):
	 #Przypisuje zmienne i tworzy okienko statystyk broni
	var popup
	if body.name == "Player":
#		if ALL_WEAPONS_STATS["Weapons"][WeaponName]["plus"]=="d1" and WeaponName==player_node.weapons[player_node.check_current_weapon()]:
#			 popup = load("res://Scenes/UI/ItemStats+.tscn")
#		else:
#			 popup = load("res://Scenes/UI/ItemStats.tscn")
		popup = load("res://Scenes/UI/ItemStats.tscn")
		popup = popup.instance()
		popup.itemName = weaponName
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
