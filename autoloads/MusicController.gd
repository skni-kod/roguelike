extends Node#autoload który pozwala na kontynuację muzyki pomiędzy scenami(w menu), można wykorzysytac później rozgrywce przy przejsciach pomiędzy lvlami.

var menu_music = load("res://Scenes/title_screen/music/roguelike7.ogg")
var soundtrack = load("res://Scenes/title_screen/music/projekt_8bit(1).ogg")
func play_music():#odpala muzykę, wywołujemy w skrypcie sceny poprzez "MusicController.play_music(): w funkcji _ready
	if $Music.stream == menu_music:#sprawdza czy dana muzyka już działa w danej scenie(żeby nie zaczynało grać muzyki od nowa przy każdym przejściu sceny
		return
	$Music.stream = menu_music
	$Music.play()

func stop_music():#zatrzymuje muzykę ,odpalamy w skrypcie sceny w której chcemy wyłączyć muzykę z menu
	$Music.stop()
