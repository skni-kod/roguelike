extends Node
func generate_room(szer, dl, tile_map, size := Vector2()):
	for x in range (szer, size.x + szer):
				for y in range(dl, size.y + dl):
					tile_map.set_cell(x,y,0)
					tile_map.update_bitmask_region(Vector2(x-1,y-1),Vector2(x+1,y+1))
