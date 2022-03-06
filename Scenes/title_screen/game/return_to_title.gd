extends Control

onready var optionsOpened = true

func _process(_delta):
	if optionsOpened:
#		$OptionsContainer/VBoxContainer2/MasterSlider.set_value(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
#		$OptionsContainer/VBoxContainer3/MusicSlider.set_value(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
#		$OptionsContainer/VBoxContainer4/SoundSlider.set_value(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds")))
		optionsOpened = false


func _on_Button_pressed():		#zmiana sceny z opcji/exitu do strony tytułowej
	get_tree().change_scene("res://Scenes/title_screen/TitleScreen.tscn")


func _on_MasterSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)


func _on_SoundSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"),value)
