# StatusBar.gd
extends Control

onready var player = get_node("../../Player")
onready var playerBody = get_node("../../Player/PlayerSprite")
onready var playerBleedingParticles = get_node("../../Player/BleedingParticles")
onready var playerBurningParticles = get_node("../../Player/BurningParticles")

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

func _ready():
	pass


# -------------- PODPALENIE -------------- #
func burn(var fire):
	if fire:
		burning = true
		playerBody.modulate = Color(1, 0.33, 0)
		playerBurningParticles.emitting = true
		$GridContainer/Burning.visible = true
		$GridContainer/Burning/Lifetime.start()
		$GridContainer/Burning/Damage.start()


func _on_Burning_Lifetime_timeout():
	burning = false
	playerBody.modulate = Color(1, 1, 1)
	playerBurningParticles.emitting = false
	$GridContainer/Burning.visible = false


func _on_Burning_Damage_timeout():
	if burning:
		player.take_dmg(burningDMG) # do przerobienia
		$GridContainer/Burning/Damage.start()


# -------------- ZAMROŻENIE -------------- #
func freeze(var freeze):
	if freeze:
		freezing = true
		speedMultiplier = 0.5
		$GridContainer/Freezing.visible = true
		$GridContainer/Freezing/Lifetime.start()


func _on_Freezing_Lifetime_timeout():
	freezing = false
	speedMultiplier = 1
	$GridContainer/Freezing.visible = false


# -------------- ODBICIE -------------- #
func knockback(var knocked_back):
	if knocked_back:
		knockback = true
		$GridContainer/Freezing.visible = true
		$GridContainer/Freezing/Lifetime.start()


func _on_Knockback_Lifetime_timeout():
	knockback = false
	$GridContainer/Knockback.visible = false


# -------------- ZATRUCIE -------------- #
func poisoning(var poisoned):
	if poisoned:
		poison = true
		playerBody.modulate = Color(0.3, 0.8, 0.1)
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
		player.take_dmg(poisonDMG) # do przerobienia
		$GridContainer/Poison/Damage.start()


# -------------- KRWAWIENIE -------------- #
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
		player.take_dmg(bleedingDMG) # do przerobienia
		$GridContainer/Bleeding/Damage.start()


# -------------- OSŁABIENIE -------------- #
func weakness(var weak):
	if weak:
		weakness = true
		damageMultiplier = 1.5
		playerBody.modulate = Color(0.3, 0.7, 1)
		$GridContainer/Weakness.visible = true
		$GridContainer/Weakness/Lifetime.start()


func _on_Weakness_Lifetime_timeout():
	weakness = false
	damageMultiplier = 1
	playerBody.modulate = Color(1, 1, 1)
	$GridContainer/Weakness.visible = false



















