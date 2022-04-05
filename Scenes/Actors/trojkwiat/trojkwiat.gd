extends StaticBody2D

# === PRELOAD (SCENY ITD.) === #
# np.: const FIREBALL_SCENE = preload("Fireball.tscn") # ładuję fireballa jako FIREBALL_SCENE
const pocisk = preload("pocisk.tscn")# = preload("res://Scenes/Actors/Laser.tscn") # wczytuję pociski
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn") # wizualny efekt zadanych obrażeń
var portal = preload("res://Scenes/Levels/Portal.tscn") # portal do przechodzenia na kolejny poziom
var portalf = preload("res://Scenes/Levels/portalf.tscn") # portal końcowy/fabularny
onready var UI := get_tree().get_root().find_node("UI", true, false)  #Zmienna przechowujaca wezel UI
# === ==================== === #

# === GRACZ === #
var gracz = null
# === ===== === #

# === HP === #
var pasek_hp
export var max_hp = 5000 # wartość życia przeciwnika
var hp:float = max_hp
# === == === #

# === HEALTHBAR === #
export var health = 100 # procentowa wartość życia do healthbara
var health_bar = preload("res://Scenes/UI/BossHealthBar.tscn").instance() # użycie paska życia bossa z folderu UI
#onready var statusEffect = UI.get_node("StatusBar") # get_node("../../../UI/StatusBar")
# === ========= === #

# == MONETY ==
var drop = {"minCoins":220,"maxCoins":240} # zakres minimalnej i maksymalnej ilości pieniędzy
var randomPosition # zmienna losowej pozycji dla coinsów
var rng = RandomNumberGenerator.new() # zmienna generująca nowy generator losowej liczby
# == ====== ==

func _ready():
	# == DODANIE PASKA HP DO UI == #
	pasek_hp = preload("res://Scenes/UI/BossHealthBar.tscn").instance()
	pasek_hp.texture_progress = load("res://Assets/Enemies/trojkwiat/hp1.png")
	pasek_hp.texture_under = load("res://Assets/Enemies/trojkwiat/hp0.png")
	get_node("../../../UI").add_child(pasek_hp)
	# == ====================== == #

func get_dmg(dmg, _weaponKnockback):
	if health>0:
		# === ZMNIEJSZANIE HP === #
		hp -= dmg # zmniejszanie hp o otrzymany dmg
		health = hp/max_hp*100 # procentowo się zmienia ilośc hp na pasku
		# === =============== === #
		# === ANIMACJE / INTERFEJS === #
		$animacja.play("hurt")
		pasek_hp.value = health # healthbar zostaje zupdateowany z nową procentową ilością hp
		# === ==================== === #
		
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true) # maska kolizji zostaje dezaktywowana aby nie móc atakować po śmierci
		# === ANIMACJE === #
		#$BodyAnimationPlayer.play("Die")
		# Czekanie na ukończenie
		#yield($BodyAnimationPlayer,"animation_finished")
		# === ======== === #
		
		# === UMIERANIE I COINSY === #
		pasek_hp.queue_free()
		drop_coins()
		emit_signal("died", self) # zostaje wyemitowany sygnał, że osa umarła
		queue_free() # instancja osy zostaje usunięta
		# === ================= === #
		
	# === WIZUALIZACJA ZADANEGO DMG === #
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)
	# === ========================= === #
	
# === ============================ === #

# === FUNKCJA OPUSZCZANIA COINSÓW I PORTALU === #
func drop_coins():
	var level = get_tree().get_root().find_node("Main", true, false) # odwołanie do node'a Main
	stworzPortal(level)
	rng.randomize() # losowanie generatora liczb
	var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"]) # wylosowanie ilości coinsów
	for _i in range(0,coins): # pętla tworząca monety
		randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10)) # precyzowanie losowej pozycji monet
		var coin = load("res://Scenes/Loot/GoldCoin.tscn") # zmienna coin to odwołanie do sceny GoldCoin.tscn
		coin = coin.instance() # coin staje się nową instacją coina
		coin.position = randomPosition # pozycją coina jest wylosowana wcześniej pozycja
		level.add_child(coin) # coin jest dzieckiem level
# === =========================== === #

func czerwony():
	$czerwony.wait_time = 1 * max(hp/max_hp,0.12)
	$czerwony.start()
	var p = pocisk.instance()
	p.position = Vector2(-23,0)
	p.Kolor = 0
	add_child(p)
	p.kierunek = p.global_position.direction_to(gracz.global_position)

func zolty():
	$zolty.wait_time = 0.5 * max(hp/max_hp,0.12)
	$zolty.start()
	var p = pocisk.instance()
	p.Kolor = 1
	add_child(p)
	p.kierunek = p.global_position.direction_to(gracz.global_position)

func niebieski():
	$niebieski.wait_time = 0.75 * max(hp/max_hp,0.12)
	$niebieski.start()
	var p = pocisk.instance()
	p.position = Vector2(23,0)
	p.Kolor = 2
	add_child(p)
	p.kierunek = p.global_position.direction_to(gracz.global_position)

func _on_Wzrok_body_entered(body):
	if body.name == "Player":
		gracz = body
		$czerwony.start()
		$zolty.start()
		$niebieski.start()
		$Wzrok.queue_free()

func _process(_delta):
	if gracz and not $animacja.is_playing():
		# == AKTUALIZUJE POŁOŻENIE OCZU ==
		if (gracz.global_position.x-global_position.x) < -35:
			$Sprite.frame = 1
		elif (gracz.global_position.x-global_position.x) > 35:
			$Sprite.frame = 2
		else:
			$Sprite.frame = 0
		# == ========================== ==

func stworzPortal(lvl):
	var p = portal.instance()
	p.global_position = get_node("../..").global_position
	if true:#Bufor.POZIOM > len(get_parent().bossScene):
		var q = portalf.instance()
		p.global_position = Vector2(get_node("../..").global_position.x - 108, get_node("../..").global_position.y)
		q.global_position = Vector2(get_node("../..").global_position.x + 108, get_node("../..").global_position.y)
		lvl.add_child(q) #Tworzy portal
	lvl.add_child(p) #Tworzy portal
