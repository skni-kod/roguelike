extends Node

var hit1 = preload("res://Assets/Sounds/hit1.ogg")
var hit2 = preload("res://Assets/Sounds/hit2.ogg")
var hit3 = preload("res://Assets/Sounds/hit3.ogg")
var hit4 = preload("res://Assets/Sounds/hit4.ogg")
var jump1 = preload("res://Assets/Sounds/jump1.ogg")
var jump2 = preload("res://Assets/Sounds/jump2.ogg")
var jump3 = preload("res://Assets/Sounds/jump3.ogg")
var jump4 = preload("res://Assets/Sounds/jump4.ogg")
var hard_step1 = preload("res://Assets/Sounds/hardground_step1.ogg")
var hard_step2 = preload("res://Assets/Sounds/hardground_step2.ogg")
var swoosh1 = preload("res://Assets/Sounds/swoosh1.ogg")

func play_hit():
	$Sound.stream = hit2
	$Sound.play()


func play_player_hit():
	$Sound.stream = hit1
	$Sound.play()


func play_player_hard_step1():
	$PlayerSound.stream = hard_step1
	$PlayerSound.play()


func play_player_hard_step2():
	$PlayerSound.stream = hard_step2
	$PlayerSound.play()


func play_player_random_hardstep():
	randomize()
	var stepsoundvar := randi() % 2
	match stepsoundvar:
		0:
			SoundController.play_player_hard_step1()
			stepsoundvar = 1
		1:
			SoundController.play_player_hard_step2()
			stepsoundvar = 0


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
	var randomNumber := randi() % 4
	match randomNumber:
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


func stop_playing():
	$Sound.stop()


func ready():
	pass
