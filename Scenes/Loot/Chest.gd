extends StaticBody2D

var rng = RandomNumberGenerator.new()
var randomPosition
var coins = rng.randf_range(3, 10)
var level
var player_node 

func _ready():
		rng.randomize()
		level = get_tree().get_root().find_node("Main", true, false)
		player_node = get_tree().get_root().find_node("Player", true, false)
		player_node.connect("open", self, "_open")
		print()
		
func _open():
	$AnimationPlayer.play("Open")
	yield($AnimationPlayer,"animation_finished")
	for i in range(0,coins):
			randomPosition = Vector2(rng.randf_range(self.position.x-10,self.position.x+10),rng.randf_range(self.position.y-10,self.position.y+10))
			var coin = load("res://Scenes/Loot/GoldCoin.tscn")
			coin = coin.instance()
			coin.position = randomPosition
			level.add_child(coin)
