extends YSort

var portal = preload("res://Scenes/Levels/Portal.tscn") # portal do przechodzenia na kolejny poziom
export var max_hp = 900
var hp = max_hp
var macka = preload("res://Scenes/Actors/OctoBoss/tentacle.tscn")
var pasek_hp
var gracz
var pozycjaMacki
var swap = null
var Timer2 = false
var drop = {"minCoins":30,"maxCoins":60} # zakres minimalnej i maksymalnej ilości pieniędzy
var randomPosition # zmienna losowej pozycji dla coinsów
var rng = RandomNumberGenerator.new() # zmienna generująca nowy generator losowej liczby

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
			#za pierwszym razem licznik czasu jest ustawiony na 1.1 s,
			#potem na 0.9 s, aby utrzymywać stały odstęp czasu
			Timer2 = true
			$Timer2.wait_time = 0.9
		var m = macka.instance()
		if pozycjaMacki == gracz.global_position:
			gracz.take_dmg(10, 1.1, Vector2(gracz.global_position.x, gracz.global_position.y + 10))
			$miniTimer.start()
			swap = m
		elif sqrt((pozycjaMacki.x - gracz.global_position.x)*(pozycjaMacki.x - gracz.global_position.x) + (pozycjaMacki.y-gracz.global_position.y)*(pozycjaMacki.y-gracz.global_position.y)) < 30:
			gracz.take_dmg(10, 1.1, m.global_position)
			$miniTimer.start()
			swap = m
		else:
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
	rng.randomize() # losowanie generatora liczb
	var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"]) # wylosowanie ilości coinsów
	for i in range (0, coins): # pętla tworząca monety
		randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10)) # precyzowanie losowej pozycji monet
		var coin = load("res://Scenes/Loot/GoldCoin.tscn") # zmienna coin to odwołanie do sceny GoldCoin.tscn
		coin = coin.instance() # coin staje się nową instacją coina
		coin.position = randomPosition # pozycją coina jest wylosowana wcześniej pozycja
		level.add_child(coin) # coin jest dzieckiem level

func _on_Wzrok_body_entered(body):
	if body.name == "Player":
		gracz = body

func _on_miniTimer_timeout():
	if swap:
		add_child(swap)
		swap.global_position = pozycjaMacki
		swap = null
