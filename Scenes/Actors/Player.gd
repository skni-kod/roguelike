extends KinematicBody2D

var velocity = Vector2.ZERO
var current_side = "Up" # Zmienna zawierająca stronę w którą odwrócony jest bohater
var attack = false # Zmienna określająca czy bohater jest w trakcie ataku
var got_hitted = false
export var speed = 2
var direction = Vector2()
export var health = 100
export var damage = 20
onready var health_bar = $Camera2D/HealthBar

func _ready():
	health_bar.on_max_health_updated(health)
	health_bar.on_health_updated(health, health)

func _physics_process(delta):
	if Input.is_action_pressed("attack"):
			$AnimationPlayer.play("Attack "+current_side)
			attack = true
			yield($AnimationPlayer,"animation_finished")
			attack = false
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
				$Sprite.scale.x = -1
			else:
				$Sprite.scale.x = 1
		elif direction.x < 0:
			$Sprite.scale.x = -1
			$AnimationPlayer.play("Run")
		elif direction.x > 0:
			$Sprite.scale.x = 1
			$AnimationPlayer.play("Run")

func take_dmg(enemy):
	health = health - enemy.dps
	health_bar.on_health_updated(health, enemy.dps)
	got_hitted = true
	$AnimationPlayer.play("Hit")
	yield($AnimationPlayer, "animation_finished")
	got_hitted = false

func _on_AttackCollision_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
