extends KinematicBody2D

var player = null
var move = Vector2.ZERO
var speed = 0.5
var dps = 5
var right = 1
var attack = false
var hp = 600

func _ready():
	pass

func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null and !attack and hp>0:
		$Sprite.scale.x = right
		move = position.direction_to(player.position) * speed
		if player.position.x-self.position.x < 0:
			right = 1
		else:
			right = -1
		$AnimationPlayer.play("Walk")
	elif !attack and hp>0:
		$AnimationPlayer.play("Idle")

	move_and_collide(move)

func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player":
		player = body

func _on_Wzrok_body_exited(body):
	player = null


func _on_Atak_body_entered(body):
	if body != self and body.name == "Player":
		attack = true

func _on_Atak_body_exited(body):
	attack = false

func _on_Timer_timeout():
	if attack and hp>0:
		$AnimationPlayer.play("Attack")
		yield($AnimationPlayer,"animation_finished")
		if attack:
			player.take_dmg(self)
			
func get_dmg(dmg):
	hp = hp - dmg
	$AnimationPlayer.play("Hurt")
	if hp<=0:
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		queue_free()
		
