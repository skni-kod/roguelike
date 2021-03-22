extends Node

var borders = Rect2(1, 1, 10, 10)

onready var tileMap = $Floor

func _ready():
	randomize()
	#generate_level()

func generate_level():
	var walker = Walker.new(Vector2(5, 5), borders)
	var map = walker.walk(5)
	walker.queue_free()
	for location in map:
		tileMap.set_cellv(location*2, rand_range(0,2))
		tileMap.set_cellv(location*2+Vector2(1,0), rand_range(0,2))
		tileMap.set_cellv(location*2+Vector2(0,1), rand_range(0,2))
		tileMap.set_cellv(location*2+Vector2(1,1), rand_range(0,2))
		
	tileMap.update_bitmask_region(borders.position, borders.end)
