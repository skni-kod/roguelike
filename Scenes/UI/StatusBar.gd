# StatusBar.gd
extends Control

# wczytanie potrzebnych node'ów w celu modyfikacji efektów statusu lub efektów wizualnych
onready var player = get_node("../../Player")
onready var playerBody = get_node("../../Player/PlayerSprite")
onready var playerBleedingParticles = get_node("../../Player/BleedingParticles")
onready var playerBurningParticles = get_node("../../Player/BurningParticles")

# zmienne setterowe/getterowe wywołujące swoje funkcje w trakcie zmiany wartości samej zmiennej
var burning := false setget burn
var freezing := false setget freeze
var knockback := false setget knockback
var poison := false setget poisoning
var bleeding := false setget bleeding
var weakness := false setget weakness

# bazowe wartości dmg zadawanego przez poszczególne efekty
var burningDMG = 3
var bleedingDMG = 3
var poisonDMG = 3

# modyfikatory danych wartości, zmieniają wartości końcowe uzyskane przez gracza
var speedMultiplier = 1
var damageMultiplier = 1
var knockbackMultiplier = 1

# funkcja ready nie wymaga żadnych operacji w tym przypadku
func _ready():
	pass


# -------------- PODPALENIE -------------- #
func burn(var fire):
	if fire:
		burning = true # ustawiam na true, ponieważ sprawdzając w ln. 35 zmienna setterowa/getterowa zostaje przywrócona do wartości domyślnej
		playerBody.modulate = Color(1, 0.33, 0) # farbuje gracza na określony kolor, w tym przypadku pomarańczowy; (R, G, B), wartości RAW
		playerBurningParticles.emitting = true # aktywuję emitowanie BurningParticle w postaci gracza
		$GridContainer/Burning.visible = true # aktywuję wyświetlanie ikonki efektu na StatusBarze
		$GridContainer/Burning/Lifetime.start() # aktywuję "czas życia" danej ikonki
		$GridContainer/Burning/Damage.start() # aktywuję "czas zadawania damage"


func _on_Burning_Lifetime_timeout():
	burning = false # wyłączam działanie efektu
	playerBody.modulate = Color(1, 1, 1) # zmieniam zafarbowanie gracza na domyślne
	playerBurningParticles.emitting = false # wyłączam emitowanie BurningParticles
	$GridContainer/Burning.visible = false # wyłączam wyświetlanie ikonki efektu na StatusBarze


func _on_Burning_Damage_timeout():
	if burning:
		player.take_dmg(burningDMG) # zadaje damage równy ilości bazowego damage danego efektu
		$GridContainer/Burning/Damage.start() # startuję "czas zadawania damage" ponownie - sekwencja zadawania damage, "Damage" ma własność One Shot, więc bez ponownego startu by nie zadawało damage przez cały okres działania efektu


# -------------- ZAMROŻENIE -------------- #
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func freeze(var freeze):
	if freeze:
		freezing = true
		speedMultiplier = 0.5 # współczynnik prędkości zostaje zmniejszony -> gracz porusza się wolniej
		$GridContainer/Freezing.visible = true
		$GridContainer/Freezing/Lifetime.start()


func _on_Freezing_Lifetime_timeout():
	freezing = false
	speedMultiplier = 1 # przywracam współczynnik prędkości do oryginalnej wartości
	$GridContainer/Freezing.visible = false


# -------------- ODBICIE -------------- #
# UWAGA     WORK IN PROGRESS      UWAGA #
# Funkcjonalność knockbacku nie jest zaimplementowana jeszcze
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func knockback(var knocked_back):
	if knocked_back:
		knockback = true
		$GridContainer/Freezing.visible = true
		$GridContainer/Freezing/Lifetime.start()


func _on_Knockback_Lifetime_timeout():
	knockback = false
	$GridContainer/Knockback.visible = false


# -------------- ZATRUCIE -------------- #
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func poisoning(var poisoned):
	if poisoned:
		poison = true
		playerBody.modulate = Color(0.3, 0.8, 0.1) # zieleń zatrucia
		$GridContainer/Poison.visible = true
		$GridContainer/Poison/Lifetime.start()
		$GridContainer/Poison/Damage.start()


func _on_Poison_Lifetime_timeout():
	poison = false
	playerBody.modulate = Color(1, 1, 1)
	$GridContainer/Poison.visible = false
	$GridContainer/Poison/Damage.stop()


func _on_Poison_Damage_timeout():
	if poison:
		player.take_dmg(poisonDMG) 
		$GridContainer/Poison/Damage.start()


# -------------- KRWAWIENIE -------------- #
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func bleeding(var bleed):
	if bleed:
		bleeding = true
		playerBody.modulate = Color(0.7, 0.1, 0)
		playerBleedingParticles.emitting = true
		$GridContainer/Bleeding.visible = true
		$GridContainer/Bleeding/Lifetime.start()
		$GridContainer/Bleeding/Damage.start()


func _on_Bleeding_Lifetime_timeout():
	bleeding = false
	playerBody.modulate = Color(1, 1, 1)
	playerBleedingParticles.emitting = false
	$GridContainer/Bleeding.visible = false
	$GridContainer/Bleeding/Damage.stop()


func _on_Bleeding_Damage_timeout():
	if bleeding:
		player.take_dmg(bleedingDMG)
		$GridContainer/Bleeding/Damage.start()


# -------------- OSŁABIENIE -------------- #
# tak samo jak w funkcji burn() (ln. 33), zmiany opisane w komentarzach
func weakness(var weak):
	if weak:
		weakness = true
		damageMultiplier = 1.5 # współczynnik damage zostaje zmieniony, player dostanie podczas osłabienia 50% więcej damage
		playerBody.modulate = Color(0.3, 0.7, 1)
		$GridContainer/Weakness.visible = true
		$GridContainer/Weakness/Lifetime.start()


func _on_Weakness_Lifetime_timeout():
	weakness = false
	damageMultiplier = 1
	playerBody.modulate = Color(1, 1, 1)
	$GridContainer/Weakness.visible = false



















