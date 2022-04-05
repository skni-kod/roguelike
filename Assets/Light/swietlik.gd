extends ColorRect

var x = 10
var y = 10

func _ready():
	set_process(true)

func _process(delta):
	rect_position.x += x*delta
	rect_position.y += y*delta

func zmianaKierunku():
	x = rand_range(-20,20)
	y = rand_range(-20,20)
