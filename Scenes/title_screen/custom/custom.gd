extends Node2D

func gotowe():
	var skorka = 0
	var peleryna = 0
	var akcesoria = 0
	if $skorki/wybor.get_selected_items().size() > 0:
		skorka = $skorki/wybor.get_selected_items()[0]-1
	if $peleryny/wybor.get_selected_items().size() > 0:
		peleryna = $peleryny/wybor.get_selected_items()[0]
	if $akcesoria/wybor.get_selected_items().size() > 0:
		akcesoria = $akcesoria/wybor.get_selected_items()[0]
	Bufor.tekstury = [skorka,akcesoria,peleryna]
	get_tree().change_scene_to(load("res://Scenes/title_screen/TitleScreen.tscn"))


func wybranaPeleryna(index):
	$manekin/peleryna.frame = index


func wybranaSkorka(index):
	if index > 0:
		$manekin.texture = load("res://Assets/Hero/Hero" + str(index-1) + ".png")
	else:
		$manekin.texture = load("res://Assets/Hero/RedHero.png")


func wybraneAkcesoria(index):
	$manekin/akcesoria.frame = index
