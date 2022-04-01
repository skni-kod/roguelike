extends Node2D

signal hammer_smash_initiated()

var mouse_position
var attacking = false
var attack_vector = Vector2.ZERO
var attack_rotation=45
export var attack_range = 5
var damage #Obrażenia zadawane przez broń. Wartość pobierana z pliku
var abilityDamage=0 #Temporary variable: Holds additional damaga inflicted by ability
var abilityManaCost=25
var weaponKnockback
var spell = 0
var weaponName = "Hammer"
var isWeaponReady = true #Sprawdź czy broń jest gotowa do ataku
var smoothing = 1

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

#do um 1
var ability1KncMultiplier = 20
var ability1DmgMultiplier = 0.75

#do um 2
var ability2DmgMultiplier = 3


func _enter_tree() -> void:
# warning-ignore:return_value_discarded
	connect("hammer_smash_initiated", Bufor.PLAYER.get_node("Hand"), "_on_hammer_smash_initiated")


func _ready() -> void:
	damage = float(Weapons.all_weapons.Katana["attack"])
	weaponKnockback = float(Weapons.all_weapons.Katana["knc"])
	$AnimationPlayer.play("RESET")


func _unhandled_input(_delta):
	if Input.is_action_just_pressed("use_ability_1"):
		if isWeaponReady:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.start_skill_cooldown(1, 0, 0) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				isWeaponReady = false
				var tmpKnc = weaponKnockback
				var tmpDmg = damage
				weaponKnockback *= ability1KncMultiplier
				damage *= ability1DmgMultiplier
				$AnimationPlayer.play("Knock Back")
				yield($AnimationPlayer, "animation_finished")
				weaponKnockback = tmpKnc
				damage = tmpDmg
				spell = 0
				isWeaponReady = true
		
	if Input.is_action_just_pressed("use_ability_2"):		
		if isWeaponReady:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.start_skill_cooldown(2, 0, 0) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				isWeaponReady = false
				var tmpDmg = damage
				damage *= ability2DmgMultiplier
				$AnimationPlayer.play("Jump Smash")
				yield($AnimationPlayer, "animation_finished")
				damage = tmpDmg
				spell = 0
				isWeaponReady = true


func _input(event):
	if isWeaponReady and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			isWeaponReady = false
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")
			isWeaponReady = true


func _on_Player_attacked():
	if !attacking:#Sprawdza czy broń nie jest w trakcie ataku
		attacking = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))


func emit_hammer_smash_signal() -> void:
	emit_signal("hammer_smash_initiated")


func _on_Hammer_body_entered(body):
	if body.is_in_group("Enemy"):
		print("[INFO]: Hammer damage: ", damage)
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		if crit:
			damage /= crit_damage

func play_hammer_smash_sound() -> void:
	SoundController.play_random_smash()


func play_hammer_swoosh_sound() -> void:
	SoundController.play_player_swoosh2()
