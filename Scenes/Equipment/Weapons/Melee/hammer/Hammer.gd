extends Node2D

signal hammer_smash_initiated()

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

#do um 1
var active_ability1 = 0
var damage_multipler = 3
var knockback_multipler = 15

#do um 2
var immortal_time = 5 #czas niesmiertelnosci w sekundach
var immortal_knockback = 20


func _enter_tree() -> void:
	connect("hammer_smash_initiated", Bufor.PLAYER.get_node("Hand"), "_on_hammer_smash_initiated")


func _ready() -> void:
	damage = float(Weapons.all_weapons.Katana["attack"])
	weaponKnockback = float(Weapons.all_weapons.Katana["knc"])
	attack_speed = float(Weapons.all_weapons.Katana["spd"])
	$AnimationPlayer.play("RESET")


func _physics_process(_delta):
	if Input.is_action_just_pressed("use_ability_1"):
		if active_ability1!=1 and Bufor.PLAYER.mana>=25:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.start_skill_cooldown(1, 0, 0) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				active_ability1 = 1
				var tmpDmg = damage
				damage *= damage_multipler
				$AnimationPlayer.play("Jump Smash")
				yield($AnimationPlayer, "animation_finished")
				damage = tmpDmg
				spell = 0
				active_ability1 = 0
		
	if Input.is_action_just_pressed("use_ability_2"):		
		if active_ability1!=1 and Bufor.PLAYER.mana>=50:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.start_skill_cooldown(2,50) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				var equipped_weapon := get_tree().get_root().find_node("EquippedWeapon", true, false)
				
				var tmp = {
					'position_x' : $AttackCollision.position.x,
					'position_y' : $AttackCollision.position.y,
					'scale_x' : $AttackCollision.scale.x,
					'scale_y' : $AttackCollision.scale.y,
					'damage' : equipped_weapon.damage,
					'weaponKnockback' : equipped_weapon.weaponKnockback,
				}
				
				$AttackCollision.disabled = false
				$AttackCollision.position.x = 0
				$AttackCollision.position.y = 0
#				$AttackCollision.scale.x = range_x
#				$AttackCollision.scale.y = range_y
				equipped_weapon.damage = 0
				equipped_weapon.weaponKnockback *= immortal_knockback
			
				$AttackCollision.disabled = true
				$AttackCollision.position.x = tmp['position_x']
				$AttackCollision.position.y = tmp['position_y']
				$AttackCollision.scale.x = tmp['scale_x']
				$AttackCollision.scale.y = tmp['scale_y']
				equipped_weapon.damage = tmp['damage']
				equipped_weapon.weaponKnockback = tmp['weaponKnockback']
				
				var level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
				level.get_node("Player").immortal = 1 
				var t = Timer.instance()
				t.set_wait_time(immortal_time) 
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
				level.get_node("Player").immortal = 0
				spell =0


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")


func _on_Player_attacked():
	if !attacking:#Sprawdza czy broń nie jest w trakcie ataku
		attacking = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))


func _on_EquippedWeapon_body_entered(body):#Zadaje obrażenia przy kolizji z przeciwnikiem
	if body.is_in_group("Enemy"):
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		if crit:
			damage /= crit_damage


func emit_hammer_smash_signal() -> void:
	emit_signal("hammer_smash_initiated")
