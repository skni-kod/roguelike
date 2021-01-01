extends KinematicBody2D

var player = null
var move = Vector2.ZERO
export var speed = 0.5
export var dps = 5
var right = 1
var attack = false
var max_hp = 200
var hp:float = max_hp
export var health = 100
onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")

 
func _ready():
	health_bar.on_max_health_updated(health)
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null and !attack and health>0:
		$Sprite.scale.x = right
		move = position.direction_to(player.position) * speed
		if player.position.x-self.position.x < 0:
			right = 1
		else:
			right = -1
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")

	move_and_collide(move)

func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player":
		player = body

func _on_Wzrok_body_exited(body):

	if body != self and body.name == "Player":

		player = null


func _on_Atak_body_entered(body):
	if body != self and body.name == "Player":
		attack = true

func _on_Atak_body_exited(body):
	attack = false

func _on_Timer_timeout():
	if attack and health>0:
		$AnimationPlayer.play("Attack")
		yield($AnimationPlayer,"animation_finished")
		player.take_dmg(self)
			
func get_dmg(dmg):
	if health>0:
		if player.position.x-self.position.x < 0:
			self.position.x += 10
		else:
			self.position.x -= 10
		hp -= dmg
		health = hp/max_hp*100
		$AnimationPlayer.play("Hurt")
		health_bar.on_health_updated(health)
		health_bar.visible = true
	if health<=0:
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		queue_free()
		
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
		
