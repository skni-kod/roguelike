extends TextEdit

var itemName
var itemAttack
var itemSpd
var itemKnc
var itemDescription
var sizeX

func _ready():
	$MarginContainer/Grid/Name.text = itemName
	$MarginContainer/Grid/Stats.text = "Attack: "+itemAttack+"\n"+"AttackSpeed: "+itemSpd+"\n"+"Knockback: "+itemKnc
