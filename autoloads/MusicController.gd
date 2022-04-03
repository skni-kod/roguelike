extends Node#autoload który pozwala na kontynuację muzyki pomiędzy scenami(w menu), można wykorzysytac później rozgrywce przy przejsciach pomiędzy lvlami.

var menu_music = load("res://Assets/Music/roguelike7.ogg")
var soundtrack = load("res://Assets/Music/projekt_8bit.ogg")


func _ready() -> void:
	play_menu_music()


func play_menu_music():#odpala muzykę, wywołujemy w skrypcie sceny poprzez "MusicController.play_menu_music(): w funkcji _ready
	$Music.stream = menu_music
	$Music.play()

func play_game_music():
	$Music.stream = soundtrack
	$Music.play()

func stop_music():#zatrzymuje muzykę ,odpalamy w skrypcie sceny w której chcemy wyłączyć muzykę z menu
	$Music.stop()
