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
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)


func _on_SoundSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"),value)
