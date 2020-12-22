extends KinematicBody2D

var motion = Vector2()
var current_side = "Up" #Sprawdza w którą stronę odwrócony jest bohater
var attack = false # Sprawdza czy bohater jest w trakcie ataku
export var speed = 3

func _physics_process(delta):
	motion = Vector2()
	if Input.is_action_pressed("attack"):
			$AnimationPlayer.play("Attack "+current_side)
			attack = true
			yield($AnimationPlayer,"animation_finished")
			attack = false
	elif !attack: #Jeżeli nie atakuje to
		if Input.is_action_pressed("down"): #Idź w określoną stronę
			motion.y = speed
			$AnimationPlayer.play("Walk Down")
		elif Input.is_action_pressed("up"):
			motion.y = -speed
			$AnimationPlayer.play("Walk Up")
		elif Input.is_action_pressed("left"):
			motion.x = -speed
			$AnimationPlayer.play("Walk Left")		
		elif Input.is_action_pressed("right"):
			motion.x = speed
			$AnimationPlayer.play("Walk Right")
		else: # Lub stój 
			$AnimationPlayer.play("Idle " + current_side)
	move_and_collide(motion)

func _on_AnimationPlayer_animation_started(anim_name): #Pobierz ostatnią animację
	current_side = anim_name.split(" ")[-1] #i weź z jej nazwy stronę
