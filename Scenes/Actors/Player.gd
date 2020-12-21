extends KinematicBody2D

const POSITION = Vector2(0,-1)

var motion = Vector2()
var anim = "Idle Up"
var attack = false

func _ready():
	pass 

func _physics_process(delta):
	motion = Vector2()
	if !attack:
		if Input.is_action_pressed("down"):
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
		elif Input.is_action_pressed("attack"):
			$AnimationPlayer.play("Attack "+anim)
			attack = true
			yield($AnimationPlayer,"animation_finished")
			attack = false
		else:
			$AnimationPlayer.play("Idle "+anim)
	move_and_collide(motion)

func _on_AnimationPlayer_animation_started(anim_name):
	anim = anim_name
	anim = anim.split(" ")
	anim = anim[1]
