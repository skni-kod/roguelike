extends StaticBody2D

var rng = RandomNumberGenerator.new() #Maszyna Lotto (losuje liczby)
var randomPosition #Pozycja wypadającego ze skrzynki coina
var coins = rng.randf_range(3, 10) #Losowa liczba coinów które wypadną ze skrzynki
var level #Zmienna przeznaczona do przechowywania odniesienia do węzła mapy
var player_node #Zmienna przeznaczona do przechowywania odniesienia do węzła gracza
var opened = false #Czy skrzynka jest otwarta

func _ready():
		rng.randomize() #Randomizuje losowanie cyfr
		level = get_tree().get_root().find_node("Main", true, false) #Pobranie węzła mapy
		player_node = get_tree().get_root().find_node("Player", true, false) #Pobranie węzła gracza
		player_node.connect("open", self, "_open") #Połączenie niezbędne do odbierania sygnału od węzła gracza
		print()
		
func _open(): #Wykonuje się gdy zostanie odebrany sygnał "open" od gracza
	if !opened: #Jeśli skrzynia nie jest otworzona to:
		opened = true #Zmień status na true
		$AnimationPlayer.play("Open") #Odtwórz animację otwierania
		yield($AnimationPlayer,"animation_finished") #Poczekaj aż animacja się zakończy
		for i in range(0,coins): #Pętla tworząca coiny
				randomPosition = Vector2(rng.randf_range(self.position.x-10,self.position.x+10),rng.randf_range(self.position.y-10,self.position.y+10)) #Wylosuj pozycję
				var coin = load("res://scenes/loot/objects/objects_scripts/GoldCoin.gd") #Załaduj scenę coina
				coin = coin.instance()
				coin.position = randomPosition #Nadaj coinowi losową pozycję
				level.add_child(coin) #Dodaj węzeł coina do węzła mapy 
