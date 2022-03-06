extends Node

var hit1 = preload("res://Assets/Sounds/hit1.ogg")
var hit2 = preload("res://Assets/Sounds/hit2.ogg")
var hit3 = preload("res://Assets/Sounds/hit3.ogg")
var hit4 = preload("res://Assets/Sounds/hit4.ogg")
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


func play_player_swoosh1():
	$WeaponSound.stream = swoosh1
	$WeaponSound.play()


func stop_playing():
	$Sound.stop()


func ready():
	pass
