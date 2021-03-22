extends Control


func _on_Button_pressed():		#zmiana sceny z opcji/exitu do strony tytułowej
	get_tree().change_scene("res://Scenes/title_screen/TitleScreen.tscn")


func _on_HSlider_value_changed(value): #zmiana master volume(na przyszłość można dodać więcej suwaków i kontrolować osobno soundtrack,sfx,menu music i coś jeszcze ,dodając do każdego suwaka kolejne nazwy zamiast "master")
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)
