extends ColorRect

onready var profile_image=get_node("MarginContainer/HBoxContainer/CenterContainer/TextureRect")
onready var class_label=get_node("MarginContainer/HBoxContainer/VBoxContainer/Class/Data")
onready var health_label=get_node("MarginContainer/HBoxContainer/VBoxContainer/Health/Data")
onready var strength_label=get_node("MarginContainer/HBoxContainer/VBoxContainer/Strength/Data")
onready var intelligence_label=get_node("MarginContainer/HBoxContainer/VBoxContainer/Intelligence/Data")
func _ready():
	var class_data = load("res://Scenes/class_select/Knight.tres")
	update_class_display(class_data)
	
func update_class_display(class_data):
	profile_image.texture=class_data.profile
	class_label.text=class_data.type
	health_label.text=str(class_data.health)
	strength_label.text=str(class_data.strength)
	intelligence_label.text=str(class_data.intelligence)
