extends Control

onready var health_bar = $HealthBar
onready var update_tween = $UpdateTween


func _on_Player_max_health_updated(max_health):
	health_bar.max_health = max_health


func _on_Player_health_update(health, amount):
	health_bar.value = health
