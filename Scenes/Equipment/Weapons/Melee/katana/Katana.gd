extends Node2D

signal katana_ability1_used(dashDestination)

onready var player_node = get_tree().get_root().find_node("Player", true, false)

var mouse_position
var attacking = false
var attack_vector = Vector2.ZERO
var attack_rotation=45
export var attack_range = 5
var damage #Obrażenia zadawane przez broń. Wartość pobierana z pliku
var passiveAbilityDamageMultiplier=0.35 #Pasywna umiejętność, dodatkowe obrażenia w procentach
var passiveAbilityStacks=0 #Obecny stopień umiejętności
var passiveAbilityMaxStacks=20 #Maksymalny stopień umiejętności
var abilityDamage=0 #Temporary variable: Holds additional damaga inflicted by ability
var abilityManaCost=25
var weaponKnockback
var spell = 0
var weaponName = "Katana"
var isWeaponReady=1 #Sprawdź czy broń jest gotowa do ataku
var smoothing = 1

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

var ability1DamageMultiplier = 3.5
var comboDmgCounter = 1

var attack_speed=0 #Animacja ataku
var isEnemyHit = 0


func _enter_tree() -> void:
	if Bufor.PLAYER != null:
		# warning-ignore:return_value_discarded
		connect("katana_ability1_used", Bufor.PLAYER.get_node("Hand"), "_on_katana_dash_used")


func _ready() -> void:
	damage = float(Weapons.all_weapons.Katana["attack"])
	weaponKnockback = float(Weapons.all_weapons.Katana["knc"])
	attack_speed = float(Weapons.all_weapons.Katana["spd"])
	$AnimationPlayer.play("RESET")


func _physics_process(_delta):
	pass


func _input(event):
	if Input.is_action_just_pressed("attack") and isWeaponReady:
		isWeaponReady = false
		$AnimationPlayer.play("Attack")
		yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("RESET")
		isWeaponReady = true


func _unhandled_input(_event):
	if Input.is_action_just_pressed("use_ability_1") and isWeaponReady:
		#Really powerful blow - 40 bonus damage
		if player_node.mana>=25:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				isWeaponReady = false
				player_node.start_skill_cooldown(1, 0, 0) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				var tmpDmg = damage
				damage *= ability1DamageMultiplier
				$AnimationPlayer.play("Dash")
				yield($AnimationPlayer, "animation_finished")
				damage = tmpDmg
				spell = 0
				$AnimationPlayer.play("RESET")
				isWeaponReady = true
				
	if Input.is_action_just_pressed("use_ability_2") and isWeaponReady:
		if player_node.mana>=50:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				isWeaponReady = false
				player_node.start_skill_cooldown(2, 0, 0) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				abilityDamage=45
				var tmpDmg = damage
				$AnimationPlayer.play("Combo Hit")
				yield($AnimationPlayer, "animation_finished")
				damage = tmpDmg
				comboDmgCounter = 1
				spell = 0
				$AnimationPlayer.play("RESET")
				isWeaponReady = true


func _on_Player_attacked():
	if !attacking and attack_speed==0:
		attacking = true
		isWeaponReady=0
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))	
		$AttackCollision.disabled = false


func _on_Katana_body_entered(body):
	if body.is_in_group("Enemy"):
		isEnemyHit=1	
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)	
		if crit:
			damage /= crit_damage
		abilityDamage=0 #Reset ability damage
		

# === SWOOSH SOUND FUNCTION === #
func play_swoosh() -> void:
	SoundController.play_player_swoosh1()
# === ===================== === #


# === SET/GET FOR THE ATTACK STATE === #
# setter is called at the animations
func set_attack_state(value: bool) -> void:
	attacking = value


# getter is called at _unhandled_input() to check if not already attacking
func get_attack_state() -> bool:
	return attacking
# === ============================ === #


# === SIGNAL EMMISSION FUNCTIONS === #
func emit_dash_signal() -> void:
	print("[INFO]: Katana dash signal emmited")
	emit_signal("katana_ability1_used", get_global_mouse_position())
# === ========================== === #


# === COMBO COUNTER FUNCTION === #
func combo_counter_increment() -> void:
	damage *= 1 + comboDmgCounter
	print("[INFO]: Katana combo damage: ", damage)
	comboDmgCounter += 1
# === ====================== === #
