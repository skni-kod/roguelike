extends Node2D
class_name Random
signal started
signal finished


#enum Cell {WALL, FLOOR, OBSTACLE}
#export(float, 0, 1) var ground_probability := 0.5

var size := Vector2(15,10) #rozmiar planszy
onready var _tile_map : TileMap = $TileMap # $TileMap == get.node("TileMap")
var _rng := RandomNumberGenerator.new() 
var dl = size.y
var szer = size.x
var gen = 0
var step = 6
var hist = 0
func _ready(): #funkcja wykonująca
	_rng.randomize()
	setup()
	generate()
	
func setup(): #funkcja, która ustawia wymiary okna (można bardziej zmodyfikować)
	OS.set_window_size(Vector2(1300,600))

func generate(): #właściwa funkcja generująca z sygnałami
	emit_signal("started")
	generate_perimeter()
	emit_signal("finished")

func generate_perimeter(): #generacja pokoju
	for n in 4:
		for m in step:
			for x in range (szer, size.x + szer):
				for y in range(dl, size.y + dl):
					_tile_map.set_cell(x,y,0)
					_tile_map.update_bitmask_region(Vector2(x-1,y-1),Vector2(x+1,y+1)) #odniesienie do Room_gen.gd
			if hist == 0: #rysowanie w górę
				if m < 2: # pierwsze 2 pokoje są prosto
					dl -= size.y + 1
				else: #kolejnie pokoje losują, w którą stronę się rysują
					gen = _rng.randi_range(0,10)
					if gen >= 0 and gen <= 6: #prosto
						dl -= size.y + 1
					elif gen > 6 and gen <= 8: #prawo
						szer += size.x + 1
					elif gen > 8 and gen <= 10: #lewo
						szer -= size.x + 1
			elif hist == 1: #rysowanie w prawo
				if m < 2:
					szer += size.x + 1 #prawo
				else:
					gen = _rng.randi_range(0,10)
					if gen >= 0 and gen <= 6: #prawo
						szer += size.x + 1
					elif gen > 6 and gen <= 8: #dół
						dl += size.y + 1
					elif gen > 8 and gen <= 10: #góra
						dl -= size.y + 1
			elif hist == 2: #rysowanie w dół
				if m < 2:
					dl += size.y + 1 #dół
				else:
					gen = _rng.randi_range(0,10)
					if gen >= 0 and gen <= 6: #dół
						dl += size.y + 1
					elif gen > 6 and gen <= 8: #prawo
						szer += size.x + 1
					elif gen > 8 and gen <= 10: #lewo
						szer -= size.x + 1
			elif hist == 3: #rysowanie w lewo
				if m < 2:
					szer -= size.x + 1 #lewo
				else:
					gen = _rng.randi_range(0,10)
					if gen >= 0 and gen <= 6: #lewo
						szer -= size.x + 1
					elif gen > 6 and gen <= 8: #dół
						dl += size.y + 1
					elif gen > 8 and gen <= 10: #góra
						dl -= size.y + 1
		szer = size.x
		dl = size.y
		hist += 1
#			if spr == 0:
#				gen = _rng.randi_range(1,3)
#			elif spr == 1:
#				while gen == 1:
#					gen = _rng.randi_range(0,3)
#			elif spr == 2:
#				while gen == 2:
#					gen = _rng.randi_range(0,3)
#			elif spr == 3:
#				gen = _rng.randi_range(0,2)
#			if gen == 0:
#				szer += size.x
#				step_history_x.append(szer)
#				dl += 0
#				spr = 0
#			elif gen == 1:
#				szer += 0
#				dl += size.y
#				step_history_x.append(dl)
#				spr = 1
#			elif gen == 2:
#				szer += -size.x
#				step_history_x.append(szer)
#				dl += 0
#				spr = 2
#			elif gen == 3:
#				szer += 0
#				dl += -size.y
#				step_history_x.append(dl)
#				spr = 3
####
#		gen = _rng.randi_range(0,1)
#		if gen == 0:
#			szer += size.x
#		else:
#			dl += size.y
#		while (szer in step_history_x) or (dl in step_history_y):
#			gen = _rng.randi_range(0,1)
#			if gen == 0:
#				szer -= 2*size.x
#				dl -= size.y
#			else:
#				szer -= size.x
#				dl -= 2*size.y
#		step_history_x.append(szer)
#		step_history_x.append(dl)
#####

#func get_random_tile(probability: float) -> int: #losowanie podłogi lub przeszkody (obecnie nieużywane)
#	return _pick_random_texture(Cell.FLOOR) #if _rng.randf() > probability else _pick_random_texture(Cell.OBSTACLE)
#
#func _pick_random_texture(cell_type: int): #losowanie tekstury z TileMap
#	var interval
#	if cell_type == Cell.WALL:
#		interval = 0
#	elif cell_type == Cell.FLOOR:
#		interval = 0
#	elif cell_type == Cell.OBSTACLE:
#		interval = 1
#	return interval
