extends Node2D

var rand = RandomNumberGenerator.new() #Losowa generacja numeru

func _ready():
	# nadpisuje domyślną generację pozycji przeciwników
	# aby pszczoły nie pojawiały się w ścianach
	position = Vector2(0,0) # węzeł rój powinien znajdować się na pozycji 0,0
	for i in get_children(): # dla każdej pszczoły jest losowana pozycja w środku węzła
		rand.randomize()
		i.position.x = rand.randf_range(-180,180) #pozycja x
		rand.randomize()
		i.position.y = rand.randf_range(-80,80) #pozycja y
