extends Control

onready var optionsOpened = true

func _process(_delta):
	if optionsOpened:
		optionsOpened = false


func _on_Button_pressed():		#zmiana sceny z opcji/exitu do strony tytułowej
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/title_screen/TitleScreen.tscn")


func _on_MasterSlider_value_changed(value):
	if value < $OptionsContainer/VBoxContainer2/MasterSlider.min_value + 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		print("[INFO]: Master muted (Options)")
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)


func _on_MusicSlider_value_changed(value):
	if value < $OptionsContainer/VBoxContainer3/MusicSlider.min_value + 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
		print("[INFO]: Music muted (Options)")
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)


func _on_SoundSlider_value_changed(value):
	if value < $OptionsContainer/VBoxContainer4/SoundSlider.min_value + 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds"), true)
		print("[INFO]: Sounds muted (Options)")
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"),value)
