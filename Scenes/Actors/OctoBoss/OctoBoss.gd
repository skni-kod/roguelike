extends StaticBody2D

export var max_hp = 900
var hp = max_hp
var macka = preload("res://Scenes/Actors/OctoBoss/tentacle.tscn")
var pasek_hp
var gracz
var pozycjaMacki
var Timer2 = false

func _ready():
	pasek_hp = preload("res://Scenes/UI/BossHealthBar.tscn").instance()
	get_node("../UI").add_child(pasek_hp)
	gracz = get_parent().get_node("Player")

func _on_Timer_timeout():
	$AnimationPlayer.play("mrug") #odtwarza animację mrugnięcia
	pozycjaMacki = gracz.position #pobiera pozycję gracza

func _on_Timer2_timeout(): #0.2s po poprzednim
	if (!Timer2): 
		#za pierwszym razem licznik czasu jest ustawiony na 5.2 s,
		#potem na 5 s, aby utrzymywać stały odstęp czasu
		Timer2 = true
		$Timer2.wait_time = 5
	var m = macka.instance()
	m.position = pozycjaMacki
	get_parent().add_child(m)

func dmg(dmg): #przyjmowanie obrażeń od ciosów w macki
	hp -= dmg
	pasek_hp.value = hp/max_hp * 100
	if hp <= 0:
		die()

func die():
	self.queue_free()
