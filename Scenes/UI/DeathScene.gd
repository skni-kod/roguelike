extends Node2D

func _physics_process(_delta):
	if $CanvasLayer/Button.pressed:
		var _c = get_tree().change_scene("res://Scenes/title_screen/TitleScreen.tscn")
