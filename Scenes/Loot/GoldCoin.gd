extends StaticBody2D

var rng = RandomNumberGenerator.new()

func _ready():
	$AnimationPlayer.play("Idle") #Odtwarzaj animację obracania
	#Wylosowanie liczby i odtworzenie animacji wyapadnia w lewo lub prawo
	rng.randomize()
	var random_number = rng.randi_range(0, 1)
	if (random_number == 0):
		$AnimationPlayer2.play("Drop-left")
	else:
		$AnimationPlayer2.play("Drop-right") 
