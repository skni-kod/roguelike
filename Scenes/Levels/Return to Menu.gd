extends Control

func _on_Return_to_Menu_pressed():
	MusicController.stop_music()
	get_tree().change_scene("res://Scenes/title_screen/TitleScreen.tscn")
	MusicController.play_menu_music()
