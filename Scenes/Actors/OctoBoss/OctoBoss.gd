extends StaticBody2D

var macka = preload("res://Scenes/Actors/OctoBoss/tentacle.tscn")
var gracz
var pozycjaMacki

func _ready():
	gracz = get_parent().get_node("Player")

func _on_Timer_timeout():
	$AnimationPlayer.play("mrug")
	pozycjaMacki = gracz.position

func _on_Timer2_timeout():
	var m = macka.instance()
	m.position = pozycjaMacki
	get_parent().add_child(m)
