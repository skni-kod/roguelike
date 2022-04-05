extends Node2D


func _ready() -> void:
	$CanvasLayer/Button.grab_focus()


func _on_Button_pressed() -> void:
	MusicController.stop_music()
	MusicController.play_menu_music()
	get_tree().change_scene("res://Scenes/title_screen/TitleScreen.tscn")
