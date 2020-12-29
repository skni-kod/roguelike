extends MarginContainer

export (NodePath) var player
export var zoom = 0.3

onready var grid = $MarginContainer/Grid
onready var player_marker = $MarginContainer/Grid/Hero
onready var wall_marker = $MarginContainer/Grid/Wall
onready var tiles = []

onready var icons = {"wall":wall_marker}

var grid_scale
var markers = {}

func _ready():
	player_marker.position = grid.rect_size / 2
	grid_scale = grid.rect_size / (get_viewport_rect().size * zoom)
	var map_objects = get_tree().get_nodes_in_group("minimap_objects")
	for item in map_objects:
		for i in range(0,4):
			var cells = item.get_used_cells_by_id(i)
			for j in range(0,len(cells)):
				tiles.append(cells[j])
		for i in tiles:
			var new_marker = icons["wall"].duplicate()
			grid.add_child(new_marker)
			new_marker.show()
			print(i)
			markers[new_marker] = Vector2(i.x*16,i.y*16)

func _process(delta):
	if !player:
		return
	for item in markers:
		var obj_pos = (markers[item] - get_node(player).position) * grid_scale + grid.rect_size/2
		item.position = obj_pos
	 
