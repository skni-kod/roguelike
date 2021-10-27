extends Sprite

export var colour = 5 #kolor 0-5, inna niż 0-5 = 0

func _ready():
	if (colour == 1 or colour == 2 or colour == 3 or colour == 4 or colour == 5):
		self.region_rect = Rect2(Vector2(32, 14*colour), Vector2(19, 14))
	if colour == 1: #dobieranie koloru światła pod kolor kryształu
		$Light2D.color = Color(1,0.49,1)
	elif colour == 2:
		$Light2D.color = Color(1,0.1,0)
	elif colour == 3:
		$Light2D.color = Color(1,0,0.3)
	elif colour == 4:
		$Light2D.color = Color(0.47,0,1)
	elif colour == 5:
		$Light2D.color = Color(0.55,1,0)
