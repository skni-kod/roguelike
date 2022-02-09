extends KinematicBody2D

# === PRELOAD (SCENY ITD.) === #
# np.: const FIREBALL_SCENE = preload("Fireball.tscn") # ładuję fireballa jako FIREBALL_SCENE
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn") # wizualny efekt zadanych obrażeń
var portal = preload("res://Scenes/Levels/Portal.tscn") # portal do przechodzenia na kolejny poziom
onready var UI := get_tree().get_root().find_node("UI", true, false)  #Zmienna przechowujaca wezel UI
# === ==================== === #

# === HP === #
export var max_hp = 1800 # wartość życia przeciwnika
var hp:float = max_hp
# === == === #

# === HEALTHBAR === #
var pasek_hp
export var health = 100 # procentowa wartość życia do healthbara
onready var statusEffect = UI.get_node("StatusBar") # get_node("../../../UI/StatusBar")
# === ========= === #

# === WYKRYWANIE CELU I ATAK === #
var player = null # zmienna do ktorej zostaje przypisany player gdy go wykryje
var atakuje = false # zmienna ataku (czy atakuje)
var dps = 30
# === ====================== === #

# === PORUSZANIE SIĘ === #
export var speed = 20 # prędkość własna
var move = Vector2.ZERO # wektor poruszania się (potrzebny potem)
# === ============== === #

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0.1
# === ===================== === #

var drop = {"minCoins":150,"maxCoins":300} # zakres minimalnej i maksymalnej ilości pieniędzy
var randomPosition # zmienna losowej pozycji dla coinsów
var rng = RandomNumberGenerator.new() # zmienna generująca nowy generator losowej liczby

func _ready():
	# == DODANIE PASKA HP DO UI == #
	pasek_hp = preload("res://Scenes/UI/BossHealthBar.tscn").instance()
	pasek_hp.texture_progress = load("res://Scenes/Actors/trojkwiat/HP1.png")
	pasek_hp.texture_under = load("res://Scenes/Actors/trojkwiat/HP0.png")
	get_node("../../../UI").add_child(pasek_hp)
	# == ====================== == #

func _on_Wzrok_body_entered(body): # (WYKONUJE SIĘ RAZ GDY BODY WEJDZIE DO ZASIĘGU)
	if body != self and body.name == "Player": # gdy body o nazwie Player wejdzie do Area2D o nazwie Wzrok, ustawia player jako body
		player = body

func _on_Wzrok_body_exited(body): # (WYKONUJE SIĘ RAZ GDY BODY WYJDZIE Z ZASIĘGU)
	if body != self and body.name == "Player": # gdy body o nazwie Player wyjdzie z Area2D o nazwie Wzrok, ustawia player jako body
		player = null

# === PHYSICS PROCESS === #
# _physics_process wykonuje się co klatkę, delta to zmienna czasowa, definiuje klatkę
# nie stosować _process, ponieważ działa on zależnie od prędkości sprzętu
func _physics_process(delta):
	move = Vector2.ZERO # wektor poruszania się jest zerowany z każdą klatką gry
	
	if player != null and health>0: # gdy wykryje gracza/obiekt w swoim zasięgu i żyje
		
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO:
			move = global_position.direction_to(player.global_position) * speed # poruszanie się w stronę gracza 
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		
		# === MODYFIKACJA SPRITE'ÓW === #
		if player.global_position.x - self.global_position.x < 0: # warunek odwracania się sprite względem pozycji playera (do playera, od playera)
			$Sprite.scale.x = 1 # sprite'y zostają obrócone (skalę dostosować do wymiarów)
		else:
			$Sprite.scale.x = -1 # sprite'y zostają obrócone (skalę dostosować do wymiarów)
		# === ===================== === #
		
		#$BodyAnimationPlayer.play("Walk") # Animacja chodzenia zostaje włączona
	
	elif !atakuje and health>0: # jeśli nie atakuje i żyje
		pass
	
	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO: # jeśli nie ma knockbacku
		var _m = move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0: # jeśli jest knockback, to nie może się ruszać
		knockback = move_and_slide(knockback) # poruszaj się w stronę wektora knockback
		knockback *= 0.95 # zmniejszanie wektora knockbacku z czasem o 5%
	# === ========================== === #
	
# === =============== === #

# === FUNKCJA OTRZYMYWANIA OBRAŻEŃ === #
func get_dmg(dmg, weaponKnockback):
	if health>0:
		
		# === KNOCKBACK === #
		knockback = -global_position.direction_to(player.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance # knockbackResistance danego przeciwnika obniża iloczynowo otrzymany knockback
		elif knockbackResistance <= 0.6:
			knockback /= 0.6 # knockback nie może być dzielony przez wartość mniejszą od 0.6 (za daleko by odlatywał)
		# ============ === #
			
		# === ZMNIEJSZANIE HP === #
		hp -= dmg # zmniejszanie hp o otrzymany dmg
		health = hp/max_hp*100 # procentowo się zmienia ilośc hp na pasku
		# Animacje obrażeń zostają aktywowane na sprite Body i Head
		# === =============== === #
		
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true) # maska kolizji zostaje dezaktywowana aby nie móc atakować po śmierci

		# === UMIERANIE I COINSY === #
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

# === FUNKCJA OPUSZCZANIA COINSÓW === #
func drop_coins():
	var level = get_tree().get_root().find_node("Main", true, false) # odwołanie do node'a Main
	rng.randomize() # losowanie generatora liczb
	var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"]) # wylosowanie ilości coinsów
	for _i in range(0,coins): # pętla tworząca monety
		randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10)) # precyzowanie losowej pozycji monet
		var coin = load("res://Scenes/Loot/GoldCoin.tscn") # zmienna coin to odwołanie do sceny GoldCoin.tscn
		coin = coin.instance() # coin staje się nową instacją coina
		coin.position = randomPosition # pozycją coina jest wylosowana wcześniej pozycja
		level.add_child(coin) # coin jest dzieckiem level
# === =========================== === #

# === FUNKCJA ATAKU === #
func attack():
	player.take_dmg(dps, enemyKnockback, self.global_position)
# === ============= === #
