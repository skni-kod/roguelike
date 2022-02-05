# na podstawie EnemyTemplate.gd
extends KinematicBody2D

# === SYGNAŁY === #
signal died(body) # sygnał, czy przeciwnik umarł
# === ======= === #

# === PRELOAD (SCENY ITD.) === #
# np.: const FIREBALL_SCENE = preload("Fireball.tscn") # ładuję fireballa jako FIREBALL_SCENE
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn") # wizualny efekt zadanych obrażeń
# === ==================== === #

# === PORUSZANIE SIĘ === #
export var speed = 0.5 # prędkość własna
var move = Vector2.ZERO # wektor poruszania się (potrzebny potem)
# === ============== === #

# === WIZUALNE ZMIENNE === #
# === ================ === #

# === WYKRYWANIE CELU I ATAK === #
var player = null # zmienna do ktorej zostaje przypisany player gdy go wykryje
var attack = false # zmienna ataku (czy atakuje)
var dps = 30
# === ====================== === #

# === HP === #
export var max_hp = 120 # wartość życia przeciwnika
var hp:float = max_hp
# === == === #

# === HEALTHBAR === #
export var health = 100 # procentowa wartość życia do healthbara
onready var health_bar = $HealthBar # deklaracja odwołania do node $HealthBar
# === ========= === #

# === COINS === #
var drop = {"minCoins":0,"maxCoins":5} # zakres minimalnej i maksymalnej ilości pieniędzy
var randomPosition # zmienna losowej pozycji dla coinsów
var rng = RandomNumberGenerator.new() # zmienna generująca nowy generator losowej liczby
# === ===== === #

# === ZMIENNE DLA POCISKU/BRONI === #
# np.: const SPEED = 100
# === ========================= === #

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 1.5
# === ===================== === #


# === WSTĘPNIE INICJOWANE FUNKCJE === #
# _ready wykonuje się JEDNORAZOWO na inicjalizacji przeciwnika
func _ready():
	health_bar.on_health_updated(health) # wstępne przypisanie wartości życia przeciwnika do healthbara
# === =========================== === #


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
			$Sprites.scale.x = -1 # sprite'y zostają obrócone (skalę dostosować do wymiarów)
		else:
			$Sprites.scale.x = 1 # sprite'y zostają obrócone (skalę dostosować do wymiarów)
		# === ===================== === #
		
		$BodyAnimationPlayer.play("Walk") # Animacja chodzenia zostaje włączona
	
	elif !attack and health>0: # jeśli nie atakuje i żyje
		pass
	
	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO: # jeśli nie ma knockbacku
		move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0: # jeśli jest knockback, to nie może się ruszać
		knockback = move_and_slide(knockback) # poruszaj się w stronę wektora knockback
		knockback *= 0.95 # zmniejszanie wektora knockbacku z czasem o 5%
	# === ========================== === #
	
# === =============== === #

# === POLE WIDZENIA WZROK === #
# GRUPA LAYER AREA2D "WZROK" -> ENEMY
# GRUPA COLLISION AREA2D "WZROK" -> PLAYER (JEŚLI MA WYKRYWAĆ INNE TO ZAZNACZYĆ INNE DODATKOWE COLLISION)
func _on_Wzrok_body_entered(body): # (WYKONUJE SIĘ RAZ GDY BODY WEJDZIE DO ZASIĘGU)
	if body != self and body.name == "Player": # gdy body o nazwie Player wejdzie do Area2D o nazwie Wzrok, ustawia player jako body
		player = body


func _on_Wzrok_body_exited(body): # (WYKONUJE SIĘ RAZ GDY BODY WYJDZIE Z ZASIĘGU)
	if body != self and body.name == "Player": # gdy body o nazwie Player wyjdzie z Area2D o nazwie Wzrok, ustawia player jako body
		player = null
# === ================== === #


# === POLE WIDZENIA ATAK === #
# GRUPA LAYER AREA2D "ATAK" -> ENEMY
# GRUPA COLLISION AREA2D "ATAK" -> PLAYER
func _on_Atak_body_entered(body): # (WYKONUJE SIĘ RAZ GDY BODY WEJDZIE DO ZASIĘGU)
	if body != self and body.name == "Player": # gdy body o nazwie Player wejdzie do Area2D o nazwie Atak, włącza przełącznik attack
		attack = true
		$AttackTimer.start() # gdy wchodzi player do sfery ataku, to startuje timer

func _on_Atak_body_exited(body): # (WYKONUJE SIĘ RAZ GDY BODY WYJDZIE Z ZASIĘGU)
	if body.name == "Player": # gdy body o nazwie Player wyjdzie z Area2D o nazwie Atak, wyłącza przełącznik attack
		attack = false
		$AttackTimer.stop() # gdy wychodzi player ze sfery ataku, to stopuje timer
# === ================== === #


# === TIMEOUT NODA ATTACKTIMER === #
func _on_AttackTimer_timeout():
	if attack and health>0: # gdy przełącznik attack jest włączony i Lil Devil żyje, to wykonuje funkcje
		attack()
# === ======================== === #


# === FUNCKJA ATAKU === #
func attack():
	player.take_dmg(dps, enemyKnockback, self.global_position)
# === ============= === #


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
		$BodyAnimationPlayer.play("Hurt")
		health_bar.on_health_updated(health) # healthbar zostaje zupdateowany z nową procentową ilością hp
		health_bar.visible = true
		# === =============== === #
		
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true) # maska kolizji zostaje dezaktywowana aby nie móc atakować po śmierci
		# === ANIMACJE === #
		$BodyAnimationPlayer.play("Die")
		# Czekanie na ukończenie
		yield($BodyAnimationPlayer,"animation_finished")
		# === ======== === #
		
		# === UMIERANIE I COINSY === #
		drop_coins()
		emit_signal("died", self) # zostaje wyemitowany sygnał, że Lil Devil umarł
		queue_free() # instancja Lil Devila zostaje usunięta
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
