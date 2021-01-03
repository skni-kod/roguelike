extends StaticBody2D

var WeaponName
var Stats = {"attack":"5","spd":"1","knc":"0.5"}
var popups = {}


func _ready():
	var texture = load("res://Assets/Loot/Weapons/"+WeaponName+".png")
	$Sprite.texture = texture

func _on_PopUp_body_entered(body):
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
