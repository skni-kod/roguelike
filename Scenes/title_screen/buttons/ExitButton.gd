extends Button #kod do przycisku który zamyka grę z pozycji start menu


export(String) var scene_to_load


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
