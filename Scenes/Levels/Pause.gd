extends CanvasLayer

var menu_scene = load("res://Scenes/title_screen/TitleScreen.tscn")

func _ready():
	set_visible(false)
	
func _input(event):
	
	if get_tree().current_scene.name == "TitleScreen":
		return
	
	if event.is_action_pressed("ui_cancel"):
		resume()

func _on_Resume_pressed():
	resume()

func _on_Return_to_Menu_pressed():
	get_tree().paused = false
	var err = get_tree().change_scene_to(menu_scene)
	set_visible(false)

func set_visible(is_visible):
	for node in get_children():
		node.visible = is_visible

func resume():
	set_visible(!get_tree().paused)
	get_tree().paused = !get_tree().paused


func _on_MasterSlider_value_changed(value):
	if value < $Pause/BlackOverlay/VBoxContainer/VBoxContainer2/MasterSlider.min_value + 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		print("[INFO]: Master muted (Pause)")
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)


func _on_MusicSlider_value_changed(value):
	if value < $Pause/BlackOverlay/VBoxContainer/VBoxContainer3/MusicSlider.min_value + 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
		print("[INFO]: Music muted (Pause)")
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)


func _on_SoundSlider_value_changed(value):
	if value < $Pause/BlackOverlay/VBoxContainer/VBoxContainer4/SoundSlider.min_value + 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds"), true)
		print("[INFO]: Sounds muted (Pause)")
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"),value)
