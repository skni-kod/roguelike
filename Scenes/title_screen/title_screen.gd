extends Control

var scene_path_to_load #ścieżka do następnej sceny jaką chcemy załadować (options/exit/start(main.tscn))


func _ready():
	$Menu/Buttons.get_child(0).grab_focus() #łapie focus na przyciski(start/options/exit...)
	for button in $Menu/Buttons.get_children(): #po naciśnięciu przycisku tworzy klasę w której podmienia ścieżkę sceny
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])


func _on_Button_pressed(scene_to_load):#dodaje animację przyciemniania przy przejściu pomiędzy scenami
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()


func _on_FadeIn_fade_finished():#przechodzi do wybranej sceny
# warning-ignore:return_value_discarded
	get_tree().change_scene(scene_path_to_load)	
	pass
 

