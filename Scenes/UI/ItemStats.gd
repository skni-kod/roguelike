extends TextEdit

var itemName
var itemAttack
var itemSpd
var itemKnc
var itemDescription
var sizeX

func _ready():
	#Generuje tekst okienka statystyk broni
	$MarginContainer/Grid/Name.text = itemName
	$MarginContainer/Grid/Stats.text = "Attack: "+itemAttack+"\n"+"AttackSpeed: "+itemSpd+"\n"+"Knockback: "+itemKnc
