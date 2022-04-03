extends Node

var hit1 = preload("res://Assets/Sounds/hit1.ogg")
var hit2 = preload("res://Assets/Sounds/hit2.ogg")
var hit3 = preload("res://Assets/Sounds/hit3.ogg")
var hit4 = preload("res://Assets/Sounds/hit4.ogg")
var smash1 = preload("res://Assets/Sounds/smash1.ogg")
var smash2 = preload("res://Assets/Sounds/smash2.ogg")
var jump1 = preload("res://Assets/Sounds/jump1.ogg")
var jump2 = preload("res://Assets/Sounds/jump2.ogg")
var jump3 = preload("res://Assets/Sounds/jump3.ogg")
var jump4 = preload("res://Assets/Sounds/jump4.ogg")
var hard_step1 = preload("res://Assets/Sounds/hardground_step1.ogg")
var hard_step2 = preload("res://Assets/Sounds/hardground_step2.ogg")
var swoosh1 = preload("res://Assets/Sounds/swoosh1.ogg")
var swoosh2 = preload("res://Assets/Sounds/swoosh2.ogg")
var mageBossLoad1 = preload("res://Assets/Sounds/mageboss_load1.wav")
var mageBossLoad2 = preload("res://Assets/Sounds/mageboss_load2.wav")
var mageBossDie = preload("res://Assets/Sounds/mageboss_die.wav")
var mageBossShoot1 = preload("res://Assets/Sounds/mageboss_shoot1.wav")
var mageBossShoot2 = preload("res://Assets/Sounds/mageboss_shoot2.wav")
var mageBossSummon1 = preload("res://Assets/Sounds/mageboss_summon1.wav")
var mageBossSummon2 = preload("res://Assets/Sounds/mageboss_summon2.wav")
var pandaBossRoar1 = preload("res://Assets/Sounds/roar1.wav")


func ready():
	pass


func play_hit():
	$Sound.stream = hit2
	$Sound.play()


func play_player_hit():
	$Sound.stream = hit1
	$Sound.play()


func play_random_smash():
	randomize()
	match randi() % 2:
		0:
			$WeaponSound.stream = smash1
		1:
			$WeaponSound.stream = smash2
	$WeaponSound.play()


func play_player_hard_step1():
	$PlayerSound.stream = hard_step1
	$PlayerSound.play()


func play_player_hard_step2():
	$PlayerSound.stream = hard_step2
	$PlayerSound.play()


func play_player_random_hardstep():
	randomize()
	match randi() % 2:
		0:
			SoundController.play_player_hard_step1()
		1:
			SoundController.play_player_hard_step2()


func play_player_jump1():
	$PlayerSound.stream = jump1;
	$PlayerSound.play()


func play_player_jump2():
	$PlayerSound.stream = jump2;
	$PlayerSound.play()


func play_player_jump3():
	$PlayerSound.stream = jump3;
	$PlayerSound.play()


func play_player_jump4():
	$PlayerSound.stream = jump4;
	$PlayerSound.play()


func play_player_random_jump():
	randomize()
	match randi() % 4:
		0:
			play_player_jump1()
		1:
			play_player_jump2()
		2:
			play_player_jump3()
		3:
			play_player_jump4()


func play_player_swoosh1():
	$WeaponSound.stream = swoosh1
	$WeaponSound.play()


func play_player_swoosh2():
	$WeaponSound.stream = swoosh2
	$WeaponSound.play()


func play_mageboss_load1() -> void:
	$BossSound.stream = mageBossLoad1
	$BossSound.play()


func play_mageboss_load2() -> void:
	$BossSound.stream = mageBossLoad2
	$BossSound.play()


func play_random_mageboss_load() -> void:
	randomize()
	match randi() % 2:
		0:
			play_mageboss_load1()
		1:
			play_mageboss_load2()


func play_mageboss_die():
	$BossSound.stream = mageBossDie
	$BossSound.play()


func play_mageboss_shoot1() -> void:
	$BossSound.stream = mageBossShoot1
	$BossSound.play()


func play_mageboss_shoot2() -> void:
	$BossSound.stream = mageBossShoot2
	$BossSound.play()


func play_random_mageboss_shoot() -> void:
	randomize()
	match randi() % 2:
		0:
			play_mageboss_shoot1()
		1:
			play_mageboss_shoot2()


func play_mageboss_summon1() -> void:
	$BossSound.stream = mageBossSummon1
	$BossSound.play()


func play_mageboss_summon2() -> void:
	$BossSound.stream = mageBossSummon2
	$BossSound.play()


func play_random_mageboss_summon() -> void:
	randomize()
	match randi() % 2:
		0:
			play_mageboss_summon1()
		1:
			play_mageboss_summon2()


func play_pandaboss_roar1() -> void:
	$BossSound.stream = pandaBossRoar1
	$BossSound.play()


func stop_playing() -> void:
	$Sound.stop()
	$BossSound.stop()
	$PlayerSound.stop()
	$WeaponSound.stop()
