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
export var health = 100 # procentowa wartość życia do healthbara
var health_bar = preload("res://Scenes/UI/BossHealthBar.tscn").instance() # użycie paska życia bossa z folderu UI
onready var statusEffect = UI.get_node("StatusBar") # get_node("../../../UI/StatusBar")
# === ========= === #

# === PORUSZANIE SIĘ === #
export var speed = 20 # prędkość własna
var move = Vector2.ZERO # wektor poruszania się (potrzebny potem)
# === ============== === #
var drop = {"minCoins":150,"maxCoins":300} # zakres minimalnej i maksymalnej ilości pieniędzy
var randomPosition # zmienna losowej pozycji dla coinsów
var rng = RandomNumberGenerator.new() # zmienna generująca nowy generator losowej liczby
var player

func _on_Wzrok_body_entered(body): # (WYKONUJE SIĘ RAZ GDY BODY WEJDZIE DO ZASIĘGU)
	if body != self and body.name == "Player": # gdy body o nazwie Player wejdzie do Area2D o nazwie Wzrok, ustawia player jako body
		player = body

func _on_Wzrok_body_exited(body): # (WYKONUJE SIĘ RAZ GDY BODY WYJDZIE Z ZASIĘGU)
	if body != self and body.name == "Player": # gdy body o nazwie Player wyjdzie z Area2D o nazwie Wzrok, ustawia player jako body
		player = null
