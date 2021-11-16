extends StaticBody2D

export var Cuckshooter = false #niebieski

func _ready():
	if (Cuckshooter):
		$Sprite.region_rect = Rect2(Vector2(51,24), Vector2(20,24))
		$Light2D.color = Color(0,1,1)
