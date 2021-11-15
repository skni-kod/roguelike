extends Sprite
#coś w rodzaju węzła "YSort"

func _on_Area2D_body_entered(body): #gracz stoi przed obiektem
	if body != self and body.name == "Player":
		self.z_index = 1


func _on_Area2D_body_exited(body): #stoi za obiektem
	if body != self and body.name == "Player":
		self.z_index = 2
