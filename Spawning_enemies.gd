extends Node

var rand = RandomNumberGenerator.new()
var enemy_scene = load("res://Scenes/Actors/Slime.tscn")
var id_list = []
var current_id
func _ready():
	pass

func _on_Node2D_body_entered(body):
	if body.name == "Player":
		current_id = get_instance_id()
		print(current_id)
		if not current_id in id_list:
			for i in range(0,5):
				var enemy = enemy_scene.instance()
				rand.randomize()
				enemy.position.x = rand.randf_range(-200,200)
				rand.randomize()
				enemy.position.y = rand.randf_range(-100,100)
				add_child(enemy)
		id_list.append(current_id)
	
