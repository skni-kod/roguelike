# PoisonousCloudModule.gd
extends Node2D
# PoisonousCloudModule - modul odpowiadajcy za tworzenie mniejszych chmur oraz zadawanie przez nie obrazen

var poisonCloud = preload("res://Scenes/Actors/PoisonousCloud/PoisonousCloud.tscn") # Wczytanie sceny pojedynczej chmury
var poisonBorder = preload("res://Scenes/ui/ui_scenes/PoisonBorder.tscn") # Wczytanie sceny obramowania informujacego gracza o przebywaniu w chmurze
var isBorder = false # Zmienna przechowuje, czy aktualnie wyswietlane jest obramowanie
var poisonBorderInst = null # Zmienna przechowujaca obramowanie
var parent = null # Zmienna przechowujaca wlasciciela modulu
onready var lastPosition = parent.global_position # Zmienna przechowujaca ostatnia pozycje wlasciciela
onready var main = get_tree().get_root().get_node("Main") # Zmienna przechowujaca wezel main
onready var statusEffect := get_tree().get_root().find_node("StatusBar", true, false) # Zmienna do status effectow

#### ========================= UWAGA =========================== ####
# Aktualnie szansa na status effect poisona jest 25%, wiec moze sprawiac
# wrazenie dosc losowego, w przyszlosci bedzie tu prawdopodobienstwo rowne
# 100% i wtedy bedzie git
#### ========================= ##### =========================== ####


func _on_TimerSpawn_timeout(): # Tworzenie mniejszych chmur
	if(!parent): # Jesli wlasciciel modulu zginal, po czasie skasuj modul
		$TimerDestroy.start()
		$TimerSpawn.stop()
		return
	var position = parent.global_position # Ustaw aktualna pozycje wlasciciela (poprawić)
	if(position.distance_to(lastPosition) > 5): # Jezeli ruszyl sie na dalej niz 5 jednostek od stworzenia ostatniej chmury, stworz nowa chmure
		lastPosition = position # Zaktualizuj ostatnia pozycje
		# Stworz chmure
		var newCloud = poisonCloud.instance() 
		newCloud.global_position = position
		# Polaczenie sygnalow ze scenami
		newCloud.connect("tick", self, "handleTick")
		newCloud.connect("quitted", self, "handleQuitted")
		# Dodaj chmure do poziomu
		main.add_child(newCloud)

func handleTick(): # Jesli mniejsza chmura wysle sygnal, ze gracz jest w chmurze
	if(!isBorder): # Stworz obramowanie jesli jeszcze go nie ma
		poisonBorderInst = poisonBorder.instance()
		get_node("../UI").add_child(poisonBorderInst)
		isBorder = true
		$TimerDealDamage.start() # Zacznij zadawac obrazenia
	$TimerQuitted.stop() # Zatrzymaj timer odliczajacy jak dlugo jestes poza chmura
	
func handleQuitted(): # Jesli mniejsza chmura wysle sygnal, ze gracz wyszedl z chmury
	$TimerQuitted.start() # Zacznij odliczac czas od kiedy wyszedl


func _on_TimerDestroy_timeout(): # Zniszcz modul po uplynieciu czasu
	queue_free()


func _on_TimerQuitted_timeout(): # Usun obramowanie oraz przestan zadawac obrazenia, jesli jestes poza chmura przez dany czas
	if(isBorder):
		poisonBorderInst.end()
		isBorder = false
		$TimerDealDamage.stop()


func _on_TimerDealDamage_timeout(): # Nakladaj status zatrucia bedac w chmurze
	if(isBorder):
		statusEffect.poison = true
