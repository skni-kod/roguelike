 extends Position2D

onready var label = get_node("Label") # zainicjowanie etykiety na obrazenia
onready var tween = get_node("Tween") # zainicjowanie animacji etykiety
var amount = 0 # przechowuje  zadane obrazenia
var type = "" # przechowuje rodzaj etykiety (zadane obrazenia)

var velocity = Vector2(0,0) # przechowuje predkosc przemieszczania etykiety

func _ready():
	label.set_text(str(amount)) # nadanie etykiecie wartosci wartosci obrazen jako tekst
	
	match type: # w zaleznosci od rodzaju etykiety
		"Damage": # jesli zadano obrazenia
			label.set("custom_colors/font_color", Color("ff4d4d")) # zmiana koloru czcionki etykiety
			
	randomize() # generowanie nowego seeda dla generatora liczb pseudolosowych
	var side_movement= randi() % 91 - 45 # przechowuje predkosc w osi X dla etkiety jako losowa liczba calkowita od 0 do 90 (-45 sprawia ze etykieta porusza sie w lewo lub prawo)
	velocity = Vector2(side_movement, 25) # predkosc etykiety
	
	tween.interpolate_property(self, 'scale', scale, Vector2(1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		# ^opis animacji powiekszenia etykiety
		# self - oznacza ze edytowana wlasciwosc 'scale znajduje sie w wezle tween'
		# 'scale' - wybiera rodzaj animacji jako zmiane wielkosci
		# scale - ustawia poczatkowa wielkosc etykiety (na te zdefiniowana domyslnie dla etykiety)
		# Vector2(1,1) - okresla rozmiar po powiekszeniu
		# 0.2 - czas animacji
		#Tween.TRANS_LINEAR, Tween.EASE_OUT - rodzaj animacji
	tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		# ^opis animacji pomniejszenia etykiety
	tween.start() # rozpoczecie animacji
	

func _on_Tween_tween_all_completed(): # po wykonaniu wszystkich animacji
	self.queue_free() # zniszcz wezel tween

func _process(delta):
	position -= velocity * delta # zmienia pozycje etykiety w oparciu o zmienna velocity
