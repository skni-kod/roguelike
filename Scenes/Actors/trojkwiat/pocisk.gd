extends Area2D

export var Kolor = 0
var kierunek = Vector2()
var szybkosc = [150, 150, 100]
var obr = [1, 1, 2]

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.take_dmg(obr[Kolor], 0, self.global_position)
		self.queue_free()

func _on_Timer_timeout():
	self.queue_free()

func _process(delta):
	position.x += kierunek.x*delta*szybkosc[Kolor]
	position.y += kierunek.y*delta*szybkosc[Kolor]
