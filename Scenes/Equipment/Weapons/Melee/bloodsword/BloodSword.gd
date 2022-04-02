extends Node2D

onready var ability2Particles = preload("res://Scenes/Equipment/Weapons/Melee/bloodsword/BloodSwordAbility2Partciles.tscn")

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2
var spell = 0;


#	Ability 1
const ability1ManaCost = 0 			# BloodSword ability 1 mana cost
const ability1Time = 3				# BloodSword time of ability
#	=========

#	Ability 2
const ability2ManaCost = 0 			# BloodSword ability 2 mana cost
var ability2Running = false			# Bool if ability2 is in progress
var ability2Target: Node = null		# Variable that holds a reference to the target of the 2nd ability 
#	=========

#	Weapon Stats
var damage
var weaponKnockback
var attack_speed = 0
var weaponName = "BloodSword" 		# potrzebne do sprawdzenia na którym miejscu jest wyekwipowane
# 	============

var isWeaponReady = true
var life_steal=0.2 #Potrzebna do pasywy, będzie mnożona przez damage


func _ready() -> void:
	damage = float(Weapons.all_weapons.Katana["attack"])
	weaponKnockback = float(Weapons.all_weapons.Katana["knc"])
	attack_speed = float(Weapons.all_weapons.Katana["spd"])
	$AnimationPlayer.play("RESET")


func _unhandled_input(_event):
	if Bufor.PLAYER and !Bufor.PLAYER.dying:
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
	if Bufor.PLAYER and !Bufor.PLAYER.dying:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed and isWeaponReady:
				isWeaponReady = false
				$AnimationPlayer.play("Attack")
				yield($AnimationPlayer, "animation_finished")
				$AnimationPlayer.play("RESET")
				isWeaponReady = true
		

func change_weapon(texture):
	$WeaponSprite.texture = texture


func ability1() -> void: # "Thirst" na krótki czas zwiększa prędkośc ataku i lifesteal
	isWeaponReady = false
	life_steal = 0.5
	$Ability1Particles.emitting = true
	yield(get_tree().create_timer(ability1Time), "timeout") #czas trwania umiejętności
	$Ability1Particles.emitting = false
	life_steal = 0.2
	isWeaponReady = true


func ability2() -> void: # "Gluttony" seria 4 ataków, każdy zadaje większe obrażenia na większej powierzchni, kosztuje życie
	isWeaponReady = false
	for n in 4:
		$AttackCollision.scale.x = 2 + n * 0.5 #wielkość ataków zależna od numeru ataku
		$AttackCollision.scale.y = (2 + n * 0.5) / 2 #dzielimy przez 2 bo wtedy tworzy się mniej więcej koło
		var tmpDmg = damage
		damage *= 1 / (n + 0.1) #zwiększamy obrażenia zależnie od numeru ataku
		ability2Running = true
		$AnimationPlayer.play("Attack")
#		var Krew = K1.instance() #towrzymy jedną instancję animacji krwi
#		Krew.visible = true
#		Krew.position = (get_tree().get_root().find_node("Player", true, false).global_position + (attack_vector*2)) #ustawiamy jej pozycję jako pozycja gracza + wektor kierunku broni
##		------------------------ #dodajemy krew do sceny
#		Krew.scale = (0.7+n*0.3)*Krew.scale #dostosowujemy wielkość krwi, używamy iteracji by była ona takiej samej wielkości co hitboxy

		yield($AnimationPlayer, "animation_finished")
		damage = tmpDmg
		if Bufor.PLAYER.health > 10:
			Bufor.PLAYER.health -= (((n + 1) * damage) / 2.2) #odbieramy życie za każdy atak, można zmienić ile
		else:
			Bufor.PLAYER.health = 10
			break
		$AnimationPlayer.play("RESET")
		Bufor.PLAYER.emit_signal("health_updated", Bufor.PLAYER.health) #emitujemy sygnał żeby pasek życia się zaktualizował
		ability2Running = false
	isWeaponReady = true


func _on_BloodSword_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):
		ability2Target = body
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		if ability2Running and !body.find_node("BloodSwordAbility2Particles"):
			var particleReference = ability2Particles
			body.call_deferred("add_child", particleReference.instance())
#			particleReference.global_position = ability2Target.global_position
		########PASSIVE######## "Transfusion" każdy atak leczy za % obrażeń
		Bufor.PLAYER.health += (life_steal*damage) #dodajemy życie zgodnie z ilością obrażeń przemnożoną przez współczynik lifestealu
		if crit:
			damage /= crit_damage
			crit = false
		if Bufor.PLAYER.health > Bufor.PLAYER.max_health: # jeśli przekroczymy max życia to ustawiamy max
			Bufor.PLAYER.health = Bufor.PLAYER.max_health
		Bufor.PLAYER.emit_signal("health_updated", Bufor.PLAYER.health) # emitujemy sygnał żeby pasek życia się zaktualizował


func _on_BloodSword_body_exited(body: Node) -> void:
	if body.is_in_group("Enemy"):
		ability2Target = null


# === SWOOSH SOUND FUNCTION === #
func play_swoosh() -> void:
	SoundController.play_player_swoosh1()
# === ===================== === #


