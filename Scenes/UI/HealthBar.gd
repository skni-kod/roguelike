extends Control

signal pulse() #definicja sygnału od animacji pulsowania

const FLASH_RATE = 0.05 #częstotliwość pulsowania
const N_FLASHES = 4 #ilość pulsów

export (Color) var healthy_color := Color.green #definicja koloru 100-50% życia
export (Color) var caution_color := Color.yellow #definicja koloru 50-25% życia
export (Color) var danger_color := Color.red #definicja koloru 25-0% życia
export (Color) var pulse_color := Color.darkred #definicja pierwszego koloru pulsowania
export (Color) var flash_color := Color.orangered #definicja drugiego koloru pulsowania
export (float , 0 , 1 , 0.05) var caution_zone := 0.5 #definicja progu zmiany koloru
export (float , 0 , 1 , 0.05) var danger_zone := 0.25 #definicja drugiego progu zmiany koloru
export (bool) var will_pulse = false #definicja zmiennej mówiącej o tym czy dany pasek życia ma pulsować

onready var health_over := $HealthOver #przypisanie do zmiennej paska życia u góry
onready var health_under := $HealthUnder #przypisanie do zmiennej paska życia na dole
onready var update_tween := $UpdateTween #przypisanie do zmiennej animacji zmiany ilości życia
onready var pulse_tween := $PulseTween #przypisanie do zmiennej pierwszej animacji pulsowania
onready var flash_tween := $FlashTween #przypisanie do zmiennej drugiej animacji pulsowania

func _ready(): #funckja wywoływana po zainicjowaniu obiektu
	var player_node := get_tree().get_root().find_node("Player", true, false) #wyszukanie i przypisanie gracza
	var _c = player_node.connect("health_updated", self, "on_Player_health_updated") #połaczenie sygnałów

func on_health_updated(health): #funkcja aktualizująca pasek życia
	health_over.value = health #przypisanie nowej ilości pkt życia
	update_tween.interpolate_property(health_under, "value", health_under.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT) #ustawienie parametrów animacji
	update_tween.start()#uruchomienie animacji

	_assign_color(health) #funkcja wybierająca kolor paska życia
#	if health < 0:
#		_flash_damage() 

func _assign_color(health): #funkcja wybierająca kolor
	if health == 0: #jeżeli życie jest równe 0
		pulse_tween.set_active(false) #wyłącz animację
	elif health < health_over.max_value * danger_zone: #jeżeli życie jest mniejsze niż próg "danger"
		if will_pulse: #jeżeli jest włączona animacja pulsowania
			if !pulse_tween.is_active(): #jeżeli animacja nie jest uruchomiona
				pulse_tween.interpolate_property(health_over, "tint_progress", pulse_color, danger_color, 1.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT) #ustawienie parametrów animacji
				update_tween.interpolate_callback(self, 0.0, "emit_signal", "pulse") #ustawienie parametrów animacji
				pulse_tween.start() #uruchom animacje
		else: #jeżeli animacja jest włączona
			health_over.tint_progress = danger_color #ustaw kolor progu "danger"
	else: #jeżeli życie nie jest mniejsze niz próg "danger"
		pulse_tween.set_active(false) #wyłącz animacje pulsowania
		if health < health_over.max_value * caution_zone: #jeżeli życie jest w progu "caution"
			health_over.tint_progress = caution_color #ustaw kolor paska na kolor progu "caution"
		else: #jeżeli życie nie jest w progu ani "caution" ani "danger"
			health_over.tint_progress = healthy_color #ustaw kolor paska życia na "healthy"

func _flash_damage(): #funkcja odpowiadająca za animację pulsowania
	for i in range(N_FLASHES * 2): 
		var color = health_over.tint_progress if i % 2 == 1 else flash_color #zmiana koloru pulsowania zależna od ilości pulsu
		var time = FLASH_RATE * i + FLASH_RATE 
		flash_tween.interpolate_callback(health_over, time, "set", "tint_progress", color) #ustawienie parametrów animacji
	flash_tween.start() #uruchom animacje

func on_Player_health_updated(health): #funkcja odpowiadająca za połączenie sygnałem między graczem a paskiem życia
	if find_parent("UI"):
		on_health_updated(health)
