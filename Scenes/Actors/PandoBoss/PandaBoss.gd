# PandaBoss.gd
extends KinematicBody2D

# === SYGNAŁY === #
signal died(body) # sygnał, czy przeciwnik umarł
# === ======= === #

# === PRELOAD (SCENY ITD.) === #
# np.: const FIREBALL_SCENE = preload("Fireball.tscn") # ładuję fireballa jako FIREBALL_SCENE
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn") # wizualny efekt zadanych obrażeń
var portal = preload("res://Scenes/Levels/Portal.tscn") # portal do przechodzenia na kolejny poziom
onready var UI := get_tree().get_root().find_node("UI", true, false)  #Zmienna przechowujaca wezel UI
# === ==================== === #

# === PORUSZANIE SIĘ === #
export var speed = 4 # prędkość własna
var move = Vector2.ZERO # wektor poruszania się (potrzebny potem)
var poruszaSie = 0 # po uderzeniu w gracza boss przez chwile nie moze sie poruszac
# === ============== === #

# === WIZUALNE ZMIENNE === #
const przod = Rect2(Vector2(0, 0),Vector2(46, 56)) # patrzy do przodu
const tyl = Rect2(Vector2(46,0),Vector2(46, 56)) # patrzy do tylu
var tylem = false # określenie czy panda stoi tyłem pozwala wyświetlić poprawną animację
var animHurt = false # żeby animacje Idle nie przerywały animacji Hurt
# === ================ === #

# === WYKRYWANIE CELU I ATAK === #
var player = null # zmienna do ktorej zostaje przypisany player gdy go wykryje
var attack = false # zmienna ataku (czy atakuje)
var player_pos = Vector2.ZERO # pozycja gracza
onready var panda_direction = Vector2.ZERO
var is_rolling = false # czy się toczy
var rolling = Vector2.ZERO
var kombo = 0 # jeżeli gracz uderzy maxKombo ilość razy, bez bycia uderzonym, może chwilowo zablokować bossa
var maxKombo = 4
# === ====================== === #

# === HP === #
export var max_hp = 720 # wartość życia przeciwnika
var hp:float = max_hp
# === == === #

# === HEALTHBAR === #
export var health = 100 # procentowa wartość życia do healthbara
var health_bar = preload("res://Scenes/UI/BossHealthBar.tscn").instance() # użycie paska życia bossa z folderu UI
onready var statusEffect = UI.get_node("StatusBar") # get_node("../../../UI/StatusBar")
# === ========= === #

# === COINS === #
var drop = {"minCoins":90,"maxCoins":120} # zakres minimalnej i maksymalnej ilości pieniędzy
var randomPosition # zmienna losowej pozycji dla coinsów
var rng = RandomNumberGenerator.new() # zmienna generująca nowy generator losowej liczby
# === ===== === #

# === ZMIENNE DLA POCISKU/BRONI I ATAKU === #
# np.: const SPEED = 100
export var dps = 20
# === ========================= === #

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 2
# === ===================== === #

# === WSTĘPNIE INICJOWANE FUNKCJE === #
# _ready wykonuje się JEDNORAZOWO na inicjalizacji przeciwnika
func _ready():
	UI.add_child(health_bar) # dodanie paska życia do UI
	# === zmiana teksturek paska życia ===
	health_bar.texture_progress = load("res://Scenes/Actors/PandoBoss/HP1.png")
	health_bar.texture_under = load("res://Scenes/Actors/PandoBoss/HP0.png")
	# === ============================ ===
	health_bar.value = health # wstępne przypisanie wartości życia przeciwnika do healthbara
# === =========================== === #

# === PHYSICS PROCESS === #
# _physics_process wykonuje się co klatkę, delta to zmienna czasowa, definiuje klatkę
# nie stosować _process, ponieważ działa on zależnie od prędkości sprzętu
func _physics_process(delta):
	move = Vector2.ZERO # wektor poruszania się jest zerowany z każdą klatką gry
	
	if player != null and health>0: # gdy wykryje gracza/obiekt w swoim zasięgu i żyje
		
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO and rolling == Vector2.ZERO:
			move = global_position.direction_to(player.global_position) * speed  * poruszaSie # poruszanie się w stronę gracza 
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		
		# === MODYFIKACJA SPRITE'ÓW === #
		if is_rolling and poruszaSie:
			var angle = (move.angle()/PI)
			if abs(angle) >= 0.75:
				$BodyAnimationPlayer.play("RollL")
			elif abs(angle) <= 0.25:
				$BodyAnimationPlayer.play("RollR")
			elif angle > -0.25 and angle < -0.75:
				$BodyAnimationPlayer.play("RollF")
			else:
				$BodyAnimationPlayer.play("RollB")
		else:
			if player.global_position.y - self.global_position.y > 0: # warunek odwracania się sprite względem pozycji playera (do playera, od playera)
				if(!$BodyAnimationPlayer.is_playing()): # wymagane do poprawnego odtwarzania animacji
					get_node("Sprites/BodySprite").region_rect = przod # odwraca się do przodu
				tylem = false # wymagane do poprawnego odtwarzania animacji
			else:
				if(!$BodyAnimationPlayer.is_playing()): # wymagane do poprawnego odtwarzania animacji
					get_node("Sprites/BodySprite").region_rect = tyl # odwraca się do tyłu
				tylem = true # wymagane do poprawnego odtwarzania animacji
			if not tylem and not animHurt:
				$BodyAnimationPlayer.play("Idle1") # Animacja Idle zostaje aktywowana
			elif not animHurt:
				$BodyAnimationPlayer.play("Idle2") # Animacja Idle zostaje aktywowana
		# === ===================== === #
	
	elif !attack and health>0: # jeśli nie atakuje i żyje
		if (!tylem):
			$BodyAnimationPlayer.play("Idle1") # Animacja Idle zostaje aktywowana
		else:
			$BodyAnimationPlayer.play("Idle2") # Animacja Idle zostaje aktywowana
	
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

# === TIMEOUT NODA ATTACKTIMER === #
func _on_AttackTimer_timeout():
	attack = true
	if player and health>0: # gdy gracz jest w polu widzenia i Panda żyje, to wykonuje funkcje
		rolling_attack()
		poruszaSie = 1
# === ======================== === #

# === FUNKCJA ATAKU === #
func rolling_attack():
	is_rolling = true
	player_pos = player.global_position
# === ============= === #

func _on_RollingArea_body_entered(body): # jeśli tocząc się trafi w gracza
	if player:
		if is_rolling and body.name == player.name:
			kombo = 0
			statusEffect.knockback = true
			poruszaSie = 0
			is_rolling = false
			attack = false
			$AttackTimer.start()
			player.take_dmg(dps, enemyKnockback, self.global_position)

# === FUNKCJA OTRZYMYWANIA OBRAŻEŃ === #
func get_dmg(dmg, weaponKnockback):
	if health>0:
		kombo += 1
		if (kombo >= maxKombo and is_rolling and attack):
			poruszaSie = 0
			is_rolling = false
			attack = false
			$AttackTimer.start()
			kombo = 0
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
		# Animacje obrażeń zostają aktywowane na sprite Body
		if not is_rolling:
			$BodyAnimationPlayer.play("Hurt")
			animHurt = true
			$animHurtTimer.start()
		health_bar.value = health # healthbar zostaje zupdateowany z nową procentową ilością hp
		# === =============== === #
	
	if health<=0:
		$CollisionPolygon2D.set_deferred("disabled", true) # maska kolizji zostaje dezaktywowana aby nie móc atakować po śmierci
		# === ANIMACJE === #
		$BodyAnimationPlayer.play("Die") # do dodania
		# Czekanie na ukończenie
		yield($BodyAnimationPlayer,"animation_finished")
		# === ======== === #
		
		# === UMIERANIE I COINSY === #
		drop_coins()
		emit_signal("died", self) # zostaje wyemitowany sygnał, że PandaBoss umarł
		health_bar.queue_free() # usunięcie paska życia
		queue_free() # instancja PandaBossa zostaje usunięta
		# === ================= === #
		
	# === WIZUALIZACJA ZADANEGO DMG === #
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
	# === ========================= === #
	
# === ============================ === #

# === KONIEC ANIMACJI HURT === #
# animacje Idle można odgrywać tylko wtedy,
# kiedy nie gra Hurt
func _on_animHurtTimer_timeout():
	animHurt = false
# === ==================== === #

# === FUNKCJA OPUSZCZANIA COINSÓW I PORTALU === #
func drop_coins():
	var level = get_tree().get_root().find_node("Main", true, false) # odwołanie do node'a Main
	var p = portal.instance()
	p.global_position = get_node("../..").global_position #dokładnie na środku pokoju
	level.add_child(p)
	rng.randomize() # losowanie generatora liczb
	var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"]) # wylosowanie ilości coinsów
	for i in range(0,coins): # pętla tworząca monety
		randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10)) # precyzowanie losowej pozycji monet
		var coin = load("res://Scenes/Loot/GoldCoin.tscn") # zmienna coin to odwołanie do sceny GoldCoin.tscn
		coin = coin.instance() # coin staje się nową instacją coina
		coin.position = randomPosition # pozycją coina jest wylosowana wcześniej pozycja
		level.add_child(coin) # coin jest dzieckiem level
# === =========================== === #
