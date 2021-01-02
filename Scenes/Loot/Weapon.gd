extends StaticBody2D

var WeaponName

func _ready():
	var texture = load("res://Assets/Loot/Weapons/"+WeaponName+".png")
	$Sprite.texture = texture

