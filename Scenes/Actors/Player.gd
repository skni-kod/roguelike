extends KinematicBody2D

var velocity = Vector2.ZERO
var current_side = "Up" # Zmienna zawierająca stronę w którą odwrócony jest bohater
var attack = false # Zmienna określająca czy bohater jest w trakcie ataku
export var speed = 2
var direction = Vector2()
var health = 10

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
	) # Określenie kierunku poruszania się
	velocity = direction * speed
	velocity = move_and_collide(velocity)
	if direction == Vector2.ZERO:
		$AnimationPlayer.play("Idle " + current_side)
	elif direction.y < 0:
		$AnimationPlayer.play("Walk Up")
	elif direction.y > 0:
		$AnimationPlayer.play("Walk Down")
	elif direction.x < 0:
		$AnimationPlayer.play("Walk Left")
	elif direction.x > 0:
		$AnimationPlayer.play("Walk Right")

func _on_AnimationPlayer_animation_started(anim_name): #Pobierz ostatnią wystartowaną animację
	current_side = anim_name.split(" ")[-1] #i weź z jej nazwy stronę w którą jest zwrócony bohater

func take_dmg(enemy):
	health = health - enemy.dps
	print(health)

func _on_AttackCollision_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(10)
