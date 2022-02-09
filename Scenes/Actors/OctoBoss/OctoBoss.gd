extends YSort

var gracz
var portal = preload("res://Scenes/Levels/portal.tscn") # portal do przechodzenia na kolejny poziom
var portalf = preload("res://Scenes/Levels/portalf.tscn") # portal końcowy/fabularny
# == PUNKTY ŻYCIA (HP) ==
export var max_hp = 900
var hp = max_hp
var pasek_hp
# == ================= ==
# == MACKI ==
var macka = preload("res://Scenes/Actors/OctoBoss/tentacle.tscn")
var pozycjaMacki # wyznaczana na podstawie pozycji gracza
var swap = null # do przerzucania instancji macki między funkcjami
var Timer2 = false
# == ===== ==
# == MONETY ==
var drop = {"minCoins":30,"maxCoins":60} # zakres minimalnej i maksymalnej ilości pieniędzy
var randomPosition # zmienna losowej pozycji dla coinsów
var rng = RandomNumberGenerator.new() # zmienna generująca nowy generator losowej liczby
# == ====== ==

func _ready():
	# == DODANIE PASKA HP DO UI == #
	pasek_hp = preload("res://Scenes/UI/BossHealthBar.tscn").instance()
	pasek_hp.texture_progress = load("res://Scenes/Actors/OctoBoss/HP1.png")
	pasek_hp.texture_under = load("res://Scenes/Actors/OctoBoss/HP0.png")
	get_node("../../../UI").add_child(pasek_hp)
	# == ====================== == #

func _on_Timer_timeout():
	if gracz:
		$AnimationPlayer.play("mrug") # odtwarza animację mrugnięcia
		pozycjaMacki = gracz.global_position # pobiera pozycję gracza

func _on_Timer2_timeout(): # 0.2s po poprzednim
	if gracz:
		if (!Timer2): 
			# za pierwszym razem licznik czasu jest ustawiony na x + 0.2 s,
			# potem na x s, aby utrzymywać stały odstęp czasu między mrugnięciem
			# a pojawieniem macki
			Timer2 = true
			$Timer2.wait_time = 0.9
		var m = macka.instance()
		if sqrt((pozycjaMacki.x - gracz.global_position.x)*(pozycjaMacki.x - gracz.global_position.x) + (pozycjaMacki.y-gracz.global_position.y)*(pozycjaMacki.y-gracz.global_position.y)) < 32:
			# jeżeli gracz znajduje się w zasięgu macki
			gracz.take_dmg(10, 1.2, Vector2(gracz.global_position.x, gracz.global_position.y + 10))
			$miniTimer.start()
			swap = m
		else: # jeżeli gracz jest na tyle daleko, że nie zostanie odepchnięty przez mackę
			add_child(m)
			m.global_position = pozycjaMacki

func dmg(dmg): # przyjmowanie obrażeń od ciosów w macki
	hp -= dmg
	pasek_hp.value = hp/max_hp * 100
	if hp <= 0:
		die()

func die(): # umieranie
	var level = get_tree().get_root().find_node("Main", true, false) # odwołanie do node'a Main
	# == TWORZY PORTAL ==
	var p = portal.instance()
	p.global_position = get_node("../..").global_position #dokładnie na środku pokoju
	level.add_child(p)
	# == ============= ==
	# == TWORZY MONETY ==
	rng.randomize() # losowanie generatora liczb
	var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"]) # wylosowanie ilości coinsów
	for _i in range (0, coins): # pętla tworząca monety
		randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10)) # precyzowanie losowej pozycji monet
		var coin = load("res://Scenes/Loot/GoldCoin.tscn") # zmienna coin to odwołanie do sceny GoldCoin.tscn
		coin = coin.instance() # coin staje się nową instacją coina
		coin.position = randomPosition # pozycją coina jest wylosowana wcześniej pozycja
		level.add_child(coin) # coin jest dzieckiem level
	# == ============= ==
	self.queue_free() # usunięcie bossa ze sceny

func _on_Wzrok_body_entered(body): # kiedy gracz wejdzie do pokoju
	if body.name == "Player": # sprawdzenie, czy to gracz
		gracz = body # przypisanie do zmiennej

func _on_miniTimer_timeout():
	if swap:
		add_child(swap)
		swap.global_position = pozycjaMacki
		swap.uderzyla = true
		swap = null

func stworzPortal(lvl):
	var p = portal.instance()
	p.global_position = get_node("../..").global_position
	if true:#Bufor.poziom > len(get_parent().bossScene):
		var q = portalf.instance()
		p.global_position = Vector2(get_node("../..").global_position.x - 108, get_node("../..").global_position.y)
		q.global_position = Vector2(get_node("../..").global_position.x + 108, get_node("../..").global_position.y)
		lvl.add_child(q) #Tworzy portal
	lvl.add_child(p) #Tworzy portal
