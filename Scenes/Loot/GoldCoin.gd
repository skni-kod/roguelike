extends StaticBody2D

var rng = RandomNumberGenerator.new()

func _ready():
	$AnimationPlayer.play("Idle") #Odtwarzaj animację obracania
	rng.randomize()
	#Wylosowanie szybkości wypadania coina
	var random_speed = rng.randf_range(0.9, 1.6)
	$AnimationPlayer2.playback_speed = random_speed
	#Wylosowanie kierunku wypadania coina
	var random_direction = rng.randi_range(0, 1)
	if (random_direction == 0):
		$AnimationPlayer2.play("Drop-left")
	else:
		$AnimationPlayer2.play("Drop-right")
