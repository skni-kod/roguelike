extends StaticBody2D

var WeaponName
var Stats = {}
var popups = {}
var weapons = {}


func _ready():
	#Pobiera wszystkie statystyki broni i zostawia sobie statystyki dla odpowiedniej broni
	var file = File.new()
	file.open("res://Jsons/ItemStats.json", file.READ)
	var text = file.get_as_text()
	weapons = JSON.parse(text).result
	Stats = weapons["Weapons"][WeaponName]
	Stats['attack'] = float(Stats['attack'])
	file.close()
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
