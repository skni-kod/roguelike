extends Node

var pozycja = [Vector2.ZERO]
var direction = Vector2.RIGHT
var rng := RandomNumberGenerator.new() 
var ilosc_pok = 4
var kierunki = [Vector2.DOWN,Vector2.UP,Vector2.RIGHT,Vector2.LEFT]
var szer = 512
var dl = 288
var gen
var scene = load("res://Scenes/Levels/Room.tscn")
func gen():
	for n in ilosc_pok:
		if n == 0:
			var pokoj = scene.instance()
			add_child(pokoj)
		else:
			var pokoj = scene.instance()
			add_child(pokoj)
			gen = rng.randi_range(0,3)
			pozycja.append(Vector2(szer,dl))
			if gen == 0:
				pokoj.position.x += szer
			elif gen == 1:
				pokoj.position.x -= szer
			if gen == 2:
				pokoj.position.y += dl
			elif gen == 3:
				pokoj.position.y -= dl
				
func _ready():
	gen()
