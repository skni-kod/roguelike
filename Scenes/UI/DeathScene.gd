extends Node2D

func _physics_process(delta):
	if $CanvasLayer/Button.pressed:
		get_tree().change_scene("res://Scenes/Levels/Main.tscn")
