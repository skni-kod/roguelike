extends KinematicBody2D

signal health_updated(health, amount)
signal max_health_updated(health)
signal attacked(damage)

var velocity = Vector2.ZERO
var current_side = "Up" # Zmienna zawierająca stronę w którą odwrócony jest bohater
var attack = false # Zmienna określająca czy bohater jest w trakcie ataku
var got_hitted = false
export var speed = 2
var direction = Vector2()
export var health = 100
export var damage = 20
var coins = 0

func _ready():
	emit_signal("max_health_updated", health)
	emit_signal("health_updated", health)
	$Camera2D/Coins.text = "Coins:"+str(coins)

func _physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		emit_signal("attacked", damage)
	elif !attack: #Jeżeli nie atakuje to
		movement()
		
func movement():
	direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() # Określenie kierunku poruszania się
	velocity = direction * speed
	velocity = move_and_collide(velocity)
	if !got_hitted:
		if direction == Vector2.ZERO:
			$AnimationPlayer.play("Idle")
		elif direction.y != 0:
			$AnimationPlayer.play("Run")
			if direction.x < 0:
				$PlayerSprite.scale.x = -1
			else:
				$PlayerSprite.scale.x = 1
		elif direction.x < 0:
			$PlayerSprite.scale.x = -1
			$AnimationPlayer.play("Run")
		elif direction.x > 0:
			$PlayerSprite.scale.x = 1
			$AnimationPlayer.play("Run")

func take_dmg(enemy):
	health = health - enemy.dps
	emit_signal("health_updated", health)
	got_hitted = true
	$AnimationPlayer.play("Hit")
	yield($AnimationPlayer, "animation_finished")
	got_hitted = false

func _on_Sword_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)

func _on_Pick_body_entered(body):
	if body.is_in_group("Pickable"):
		if "GoldCoin" in body.name:
			coins += 10
			body.queue_free()
	$Camera2D/Coins.text = "Coins:"+str(coins)
  
func _on_Player_health_updated(health):
	pass

func _on_Player_max_health_updated(health):
	pass

