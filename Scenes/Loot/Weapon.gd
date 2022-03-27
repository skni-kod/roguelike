extends StaticBody2D

var weaponName
var Stats = {}
var popups = {}
var weapons = {}
var texture = null
onready var all_weapons = Weapons.all_weapons #Wczytanie z niewidzialnego node wszystkich broni

func _ready():
	Stats = all_weapons[weaponName]
	Stats['attack'] = float(Stats['attack'])
	texture = load("res://Assets/Loot/Weapons/"+weaponName+".png")
	if weaponName == "katana":
		$Sprite.scale.x = .5
		$Sprite.scale.y = .5
	elif weaponName == "spear":
		$Sprite.scale.x = .5
		$Sprite.scale.y = .5
	else:
		$Sprite.scale.x = 1
		$Sprite.scale.y = 1
	$Sprite.texture = texture
	if (weaponName == null):
		queue_free()
#test
func take_dmg(a):
	pass
func _on_PopUp_body_entered(body):
	 #Przypisuje zmienne i tworzy okienko statystyk broni
	if body.name == "Player":
		var popup = load("res://Scenes/UI/ItemStats.tscn")
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
