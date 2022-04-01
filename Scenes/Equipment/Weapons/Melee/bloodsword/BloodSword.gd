extends Node2D

onready var K1 = $WeaponSprite/BloodParticles1 #pobieramy particle do umiejek
onready var K2 = $WeaponSprite/BloodParticles2

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2
var spell = 0;

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var attack_speed = 0
var timer #Stoper
var damage
var ability1ManaCost = 0 #koszt do zmiany w balansie
var ability2ManaCost = 0 #koszt do zmiany w balansie
var weaponKnockback
var a = 1
var weaponName = "BloodSword" #potrzebne do sprawdzenia na którym miejscu jest wyekwipowane
var smoothing = 1
var isWeaponReady = true
var life_steal=0.1 #Potrzebna do pasywy, będzie mnożona przez damage


func _ready() -> void:
	damage = float(Weapons.all_weapons.Katana["attack"])
	weaponKnockback = float(Weapons.all_weapons.Katana["knc"])
	attack_speed = float(Weapons.all_weapons.Katana["spd"])
	$AnimationPlayer.play("RESET")


func _unhandled_input(_event):
	if Input.is_action_just_pressed("use_ability_1"):
		if Bufor.PLAYER.mana>=ability1ManaCost and isWeaponReady:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.start_skill_cooldown(1, 0, ability1ManaCost) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				ability1()
				spell = 0
	
	if Input.is_action_just_pressed("use_ability_2"):
		if Bufor.PLAYER.mana>=ability2ManaCost and isWeaponReady:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.start_skill_cooldown(2, 0, ability2ManaCost) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				ability2()
				spell = 0


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")


func _on_Player_attacked():
	if !attack:#Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		

func change_weapon(texture):
	$WeaponSprite.texture = texture


func ability1(): # "Thirst" na krótki czas zwiększa prędkośc ataku i lifesteal
	isWeaponReady = false
	life_steal = 0.5
	yield(get_tree().create_timer(2), "timeout") #czas trwania umiejętności
	life_steal = 0.1
	isWeaponReady = false

func ability2(): # "Gluttony" seria 4 ataków, każdy zadaje większe obrażenia na większej powierzchni, kosztuje życie
	
	isWeaponReady = false
	
	var ticks = 2 #ilość ataków
	for n in ticks:
		$AttackCollision.scale.x = 2+n*0.5 #wielkość ataków zależna od numeru ataku
		$AttackCollision.scale.y = (2+n*0.5)/2 #dzielimy przez 2 bo wtedy tworzy się mniej więcej koło
		damage *= n+2 #zwiększamy obrażenia zależnie od numeru ataku
		_on_Player_attacked() #używamy zwykłego ataku
		
#		var Krew = K1.instance() #towrzymy jedną instancję animacji krwi
#		Krew.visible = true
#		Krew.position = (get_tree().get_root().find_node("Player", true, false).global_position + (attack_vector*2)) #ustawiamy jej pozycję jako pozycja gracza + wektor kierunku broni
##		------------------------ #dodajemy krew do sceny
#		Krew.scale = (0.7+n*0.3)*Krew.scale #dostosowujemy wielkość krwi, używamy iteracji by była ona takiej samej wielkości co hitboxy
#
#		yield(get_tree().create_timer(1), "timeout") #czas pomiędzy atakami
		damage /= n+2 #zmniejszamy obrażenia bo byśmy je wymnożyli do za dużych wartości, i żeby wszystkie ataki kosztowały tyle samo życia
		Bufor.PLAYER.health -= (((n+1)*damage)/2.2) #odbieramy życie za każdy atak, można zmienić ile
		Bufor.PLAYER.emit_signal("health_updated", Bufor.PLAYER.health) #emitujemy sygnał żeby pasek życia się zaktualizował
		
#		Krew.queue_free()
		
	isWeaponReady = true


func _on_BloodSword_body_entered(body):
	if body.is_in_group("Enemy"):
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		########PASSIVE######## "Transfusion" każdy atak leczy za % obrażeń
		Bufor.PLAYER.health += (life_steal*damage) #dodajemy życie zgodnie z ilością obrażeń przemnożoną przez współczynik lifestealu
		if crit:
			damage /= crit_damage
		if Bufor.PLAYER.health > Bufor.PLAYER.max_health: #jeśli przekroczymy max życia to ustawiamy max
			Bufor.PLAYER.health = Bufor.PLAYER.max_health
		Bufor.PLAYER.emit_signal("health_updated", Bufor.PLAYER.health) #emitujemy sygnał żeby pasek życia się zaktualizował
		
#		var Krew = K2.instance() #towrzymy jedną instancję animacji krwi
#		Krew.visible = true
#		Krew.position = (get_tree().get_root().find_node("Player", true, false).global_position + (attack_vector*2)) #ustawiamy jej pozycję jako pozycja gracza + wektor kierunku broni
#		Krew.rotation_degrees = rotation_degrees #krew idzie po tej samej lini co miecz
#		#dodajemy krew do sceny
#		Krew.scale = 1.5*Krew.scale #dostosowujemy wielkość krwi
#		yield(get_tree().create_timer(0.3), "timeout") #czas stania krwi
#		Krew.queue_free() #usuwamy krew
		#######################


# === SWOOSH SOUND FUNCTION === #
func play_swoosh() -> void:
	SoundController.play_player_swoosh1()
# === ===================== === #
