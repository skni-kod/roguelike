extends Node2D

var poisonCloud = load("res://Scenes/Actors/PoisonousCloud.tscn")
var poisonBorder = load("res://Scenes/UI/PoisonBorder.tscn")
var isBorder = false
var poisonBorderInst = null
var parent = null
onready var lastPosition = parent.global_position
onready var main = get_tree().get_root().find_node("Main",true,false)
onready var statusEffect := get_tree().get_root().find_node("StatusBar", true, false)

func _on_TimerSpawn_timeout():
	if(!parent):
		$TimerDestroy.start()
		$TimerSpawn.stop()
		return
	var position = parent.global_position
	if(position.distance_to(lastPosition) > 5):
		lastPosition = position
		var newCloud = poisonCloud.instance()
		newCloud.global_position = position
		newCloud.connect("tick", self, "handleTick")
		newCloud.connect("quitted", self, "handleQuitted")
		main.add_child(newCloud)

func handleTick():
	if(!isBorder):
		poisonBorderInst = poisonBorder.instance()
		get_node("../UI").add_child(poisonBorderInst)
		isBorder = true
		$TimerDealDamage.start()
	$TimerQuitted.stop()
	
func handleQuitted():
	$TimerQuitted.start()


func _on_TimerDestroy_timeout():
	queue_free()


func _on_TimerQuitted_timeout():
	if(isBorder):
		poisonBorderInst.end()
		isBorder = false
		$TimerDealDamage.stop()


func _on_TimerDealDamage_timeout():
	if(isBorder):
		statusEffect.poison = true
