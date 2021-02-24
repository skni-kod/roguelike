extends Node

var borders = Rect2(1, 1, 50, 50)

onready var tileMap = $Floor

func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(25, 25), borders)
	var map = walker.walk(2000)
	walker.queue_free()
	for location in map:
		tileMap.set_cellv(location*2, 1)
		tileMap.set_cellv(location*2+Vector2(1,0), 1)
		tileMap.set_cellv(location*2+Vector2(0,1), 1)
		tileMap.set_cellv(location*2+Vector2(1,1), 1)
		
	tileMap.update_bitmask_region(borders.position, borders.end)
