# StatusBar.gd
extends Control

# wczytanie potrzebnych node'ów w celu modyfikacji efektów statusu lub efektów wizualnych
onready var player = get_node("../../Player")
onready var playerBody = get_node("../../Player/PlayerSprite")
onready var playerBleedingParticles = get_node("../../Player/BleedingParticles")
onready var playerBurningParticles = get_node("../../Player/BurningParticles")

# zmienne setterowe/getterowe wywołujące swoje funkcje w trakcie zmiany wartości samej zmiennej
var burning := false setget burn
var bleeding := false setget bleeding
var poison := false setget poisoning

var freezing := false setget freeze
var knockback := false setget knockback
var weakness := false setget weakness

# bazowe wartości dmg zadawanego przez poszczególne efekty
var burningDMG = 2
var bleedingDMG = 2
var poisonDMG = 2

# modyfikatory danych wartości, zmieniają wartości końcowe uzyskane przez gracza
var speedMultiplier = 1
var damageMultiplier = 1
var knockbackMultiplier = 1

# stacki efektów
var burningStacks = 0
var freezingStacks = 0
var knockbackStacks = 0
var poisonStacks = 0
var bleedingStacks = 0
var weaknessStacks = 0

# maksymalne ilosci stacków dla danych efektów
var burningMaxStacks = 10
var freezingMaxStacks = 10
var knockbackMaxStacks = 10
var poisonMaxStacks = 10
var bleedingMaxStacks = 10
var weaknessMaxStacks = 10

# funkcja ready nie wymaga żadnych operacji w tym przypadku
func _ready():
	pass


#=============== DAMAGE EFFECTS ===============#
# -------------- PODPALENIE -------------- #
func burn(var fire):
	if fire and prawdopodobienstwo(0.5):
		if burningStacks <= burningMaxStacks: # ograniczam stacki do maksymalnej wartości stacków dla danego efektu
			burningStacks += 1 # dodaję stack
		burning = true # ustawiam na true, ponieważ sprawdzając w ln. 35 zmienna setterowa/getterowa zostaje przywrócona do wartości domyślnej
		playerBody.modulate = Color(1, 0.33, 0) # farbuje gracza na określony kolor, w tym przypadku pomarańczowy; (R, G, B), wartości RAW
		playerBurningParticles.emitting = true # aktywuję emitowanie BurningParticle w postaci gracza
		$StatusContainer/Burning.visible = true # aktywuję wyświetlanie ikonki efektu na StatusBarze
		$StatusContainer/Burning/DisplayTime/Lifetime.start() # aktywuję "czas życia" danej ikonki
		$StatusContainer/Burning/DisplayTime.timer_on = true # akttwuję skrypt wypisywania pozostałego czasu efektu na ekranie
		$StatusContainer/Burning/DisplayStacks.stacks = burningStacks # przekazuję stacki do wyświetlania na ekranie
		$StatusContainer/Burning/Damage.start() # aktywuję "czas zadawania damage"


func _on_Burning_Lifetime_timeout():
	burning = false # wyłączam działanie efektu
	burningStacks = 0 # przywracam ilość stacków do zera
	playerBody.modulate = Color(1, 1, 1) # zmieniam zafarbowanie gracza na domyślne
	playerBurningParticles.emitting = false # wyłączam emitowanie BurningParticles
	$StatusContainer/Burning.visible = false # wyłączam wyświetlanie ikonki efektu na StatusBarze
	$StatusContainer/Burning/DisplayTime.timer_on = false # wyłączam timer/wyświetlanie czasu
	$StatusContainer/Burning/DisplayStacks.stacks = 0 # resetuję ilość stacków na 0


func _on_Burning_Damage_timeout():
	if burning:
		player.take_dmg(burningDMG+(burningStacks*1.1)) # zadaje damage równy ilości bazowego damage danego efektu
		$StatusContainer/Burning/Damage.start() # startuję "czas zadawania damage" ponownie - sekwencja zadawania damage, "Damage" ma własność One Shot, więc bez ponownego startu by nie zadawało damage przez cały okres działania efektu


# -------------- ZATRUCIE -------------- #
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func poisoning(var poisoned):
	if poisoned and prawdopodobienstwo(0.75):
		if poisonStacks <= poisonMaxStacks:
			poisonStacks += 1
		poison = true
		playerBody.modulate = Color(0.3, 0.8, 0.1) # zieleń zatrucia
		$StatusContainer/Poison.visible = true
		$StatusContainer/Poison/DisplayTime/Lifetime.start()
		$StatusContainer/Poison/DisplayTime.timer_on = true
		$StatusContainer/Poison/DisplayStacks.stacks = poisonStacks
		$StatusContainer/Poison/Damage.start()


func _on_Poison_Lifetime_timeout():
	poison = false
	poisonStacks = 0
	playerBody.modulate = Color(1, 1, 1)
	$StatusContainer/Poison.visible = false
	$StatusContainer/Poison/Damage.stop()


func _on_Poison_Damage_timeout():
	if poison:
		player.take_dmg(poisonDMG+(poisonStacks*1.2)) 
		$StatusContainer/Poison/Damage.start()


# -------------- KRWAWIENIE -------------- #
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func bleeding(var bleed):
	if bleed and prawdopodobienstwo(0.9):
		if bleedingStacks <= bleedingMaxStacks:
			bleedingStacks += 1
		bleeding = true
		playerBody.modulate = Color(0.7, 0.1, 0)
		playerBleedingParticles.emitting = true
		$StatusContainer/Bleeding.visible = true
		$StatusContainer/Bleeding/DisplayTime/Lifetime.start()
		$StatusContainer/Bleeding/DisplayTime.timer_on = true
		$StatusContainer/Bleeding/DisplayStacks.stacks = bleedingStacks
		$StatusContainer/Bleeding/Damage.start()


func _on_Bleeding_Lifetime_timeout():
	bleeding = false
	bleedingStacks = 0
	playerBody.modulate = Color(1, 1, 1)
	playerBleedingParticles.emitting = false
	$StatusContainer/Bleeding.visible = false
	$StatusContainer/Bleeding/Damage.stop()


func _on_Bleeding_Damage_timeout():
	if bleeding:
		player.take_dmg(bleedingDMG+(bleedingStacks*1.5))
		$StatusContainer/Bleeding/Damage.start()


#=============== NON-DAMAGE EFFECTS ===============#
# -------------- ZAMROŻENIE -------------- #
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func freeze(var freeze):
	if freeze and prawdopodobienstwo(0.6):
		if freezingStacks <= freezingMaxStacks:
			freezingStacks += 1
		freezing = true
		if speedMultiplier > 0:
			speedMultiplier = (speedMultiplier-(pow(0.5, freezingStacks))) # współczynnik prędkości zostaje zmniejszony -> gracz porusza się wolniej
		else:
			speedMultiplier = 0 # w razie gdy jest wystarczająco stacków, w celu uniknięcia błędu przyjmuje się speedMultiplier jako 0
		playerBody.modulate = Color(0.4, 0.8, 1)
		$StatusContainer/Freezing.visible = true
		$StatusContainer/Freezing/DisplayTime/Lifetime.start()
		$StatusContainer/Freezing/DisplayTime.timer_on = true
		$StatusContainer/Freezing/DisplayStacks.stacks = freezingStacks


func _on_Freezing_Lifetime_timeout():
	freezing = false
	freezingStacks = 0
	speedMultiplier = 1 # przywracam współczynnik prędkości do oryginalnej wartości
	playerBody.modulate = Color(1, 1, 1)
	$StatusContainer/Freezing.visible = false


# -------------- ODBICIE -------------- #
# UWAGA     WORK IN PROGRESS      UWAGA #
# Funkcjonalność knockbacku nie jest zaimplementowana jeszcze
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func knockback(var knocked_back):
	if knocked_back and prawdopodobienstwo(0.5):
		if knockbackStacks <= knockbackMaxStacks:
			knockbackStacks += 1
		knockback = true
		if knockbackMultiplier > 0:
			knockbackMultiplier = (knockbackMultiplier-(pow(0.5, knockbackStacks)))
		else:
			knockbackMultiplier = 0
		$StatusContainer/Knockback.visible = true
		$StatusContainer/Knockback/DisplayTime/Lifetime.start()
		$StatusContainer/Knockback/DisplayTime.timer_on = true
		$StatusContainer/Knockback/DisplayStacks.stacks = knockbackStacks


func _on_Knockback_Lifetime_timeout():
	knockback = false
	$StatusContainer/Knockback.visible = false


# -------------- OSŁABIENIE -------------- #
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func weakness(var weak):
	if weak and prawdopodobienstwo(0.4):
		if weaknessStacks <= weaknessMaxStacks:
			weaknessStacks += 1
		weakness = true
		if damageMultiplier > 0:
			damageMultiplier = (damageMultiplier+(pow(0.5, weaknessStacks)))
		else:
			damageMultiplier = 0
		playerBody.modulate = Color(0.3, 0.7, 1)
		$StatusContainer/Weakness.visible = true
		$StatusContainer/Weakness/DisplayTime/Lifetime.start()
		$StatusContainer/Weakness/DisplayTime.timer_on = true
		$StatusContainer/Weakness/DisplayStacks.stacks = weaknessStacks


func _on_Weakness_Lifetime_timeout():
	weakness = false
	damageMultiplier = 1
	playerBody.modulate = Color(1, 1, 1)
	$StatusContainer/Weakness.visible = false


# FUNKCJA GENERUJĄCA PRAWDĘ/FAŁSZ Z PRAWDOPODOBIEŃSTWA #
func prawdopodobienstwo(var procent_prawdopodobienstwa):
	var percent = randf() # generator losowej liczby float/procentu
	if (percent > procent_prawdopodobienstwa):
		return true
	else:
		return false













