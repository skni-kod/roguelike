extends Node2D


var abilityTime = 2
var damageInterval = 0.5
var abilityDamage = 10

onready var damageTimer := Timer.new()


func _ready() -> void:
	z_index = 1
	
	var deathTimer := Timer.new()
	add_child(deathTimer)
	deathTimer.set_wait_time(abilityTime)
	deathTimer.set_one_shot(true)
	deathTimer.connect("timeout", self, "_on_deathTimer_timeout")
	deathTimer.start()
	
	damageTimer.set_wait_time(damageInterval)
	add_child(damageTimer)
	damageTimer.connect("timeout", self, "_on_damageTimer_timeout")
	damageTimer.start()
	
	
func _on_deathTimer_timeout() -> void:
	queue_free()


func _on_damageTimer_timeout() -> void:
	if Bufor.PLAYER and Bufor.PLAYER.get_node("Hand").get_child(0).weaponName == "BloodSword":
		Bufor.PLAYER.health += (Bufor.PLAYER.get_node("Hand").get_child(0).life_steal * abilityDamage)
	get_parent().get_dmg(abilityDamage, 0)
