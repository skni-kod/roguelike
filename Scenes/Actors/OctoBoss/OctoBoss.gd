extends YSort

var portal = preload("res://Scenes/Levels/Portal.tscn") # portal do przechodzenia na kolejny poziom
export var max_hp = 900
var hp = max_hp
var macka = preload("res://Scenes/Actors/OctoBoss/tentacle.tscn")
var pasek_hp
var gracz
var pozycjaMacki
var Timer2 = false

func _ready():
	pasek_hp = preload("res://Scenes/UI/BossHealthBar.tscn").instance()
	get_node("../../../UI").add_child(pasek_hp)

func _on_Timer_timeout():
	if gracz:
		$AnimationPlayer.play("mrug") #odtwarza animację mrugnięcia
		pozycjaMacki = gracz.global_position #pobiera pozycję gracza

func _on_Timer2_timeout(): #0.2s po poprzednim
	if gracz:
		if (!Timer2): 
			#za pierwszym razem licznik czasu jest ustawiony na 5.2 s,
			#potem na 5 s, aby utrzymywać stały odstęp czasu
			Timer2 = true
			$Timer2.wait_time = 5
		var m = macka.instance()
		add_child(m)
		m.global_position = pozycjaMacki

func dmg(dmg): #przyjmowanie obrażeń od ciosów w macki
	hp -= dmg
	pasek_hp.value = hp/max_hp * 100
	if hp <= 0:
		die()

func die():
	var level = get_tree().get_root().find_node("Main", true, false) # odwołanie do node'a Main
	var p = portal.instance()
	p.global_position = get_node("../..").global_position #dokładnie na środku pokoju
	level.add_child(p)
	self.queue_free()

func _on_Wzrok_body_entered(body):
	if body.name == "Player":
		gracz = body
