extends KinematicBody2D

const POSITION = Vector2(0,-1)

var motion = Vector2()
var current_side = "Up"
var attack = false

func _ready():
	pass 

func _physics_process(delta):
	motion = Vector2()
	if !attack:
		if Input.is_action_pressed("attack"):
			$AnimationPlayer.play("Attack " + current_side)
			attack = true
			if current_side == "Up":
				$AttackCollision/AttackUp.disabled = false
			elif current_side == "Down":
				$AttackCollision/AttackDown.disabled = false
			elif current_side == "Left":
				$AttackCollision/AttackLeft.disabled = false
			elif current_side == "Right":
				$AttackCollision/AttackRight.disabled = false
			yield($AnimationPlayer,"animation_finished")
			$AttackCollision/AttackUp.disabled = true
			$AttackCollision/AttackDown.disabled = true
			$AttackCollision/AttackLeft.disabled = true
			$AttackCollision/AttackRight.disabled = true
			attack = false
		elif Input.is_action_pressed("down"):
			motion.y = 5
			$AnimationPlayer.play("Walk Down")
		elif Input.is_action_pressed("up"):
			motion.y = -5
			$AnimationPlayer.play("Walk Up")
		elif Input.is_action_pressed("left"):
			motion.x = -5
			$AnimationPlayer.play("Walk Left")		
		elif Input.is_action_pressed("right"):
			motion.x = 5
			$AnimationPlayer.play("Walk Right")
		else:
			$AnimationPlayer.play("Idle " + current_side)
	move_and_collide(motion)

func _on_AnimationPlayer_animation_started(anim_name):
	current_side = anim_name.split(" ")[-1]
