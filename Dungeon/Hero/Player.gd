extends KinematicBody2D

const POSITION = Vector2(0,-1)

var motion = Vector2()
var anim = "IdleUp"
var attack = false

func _ready():
	pass 

func _physics_process(delta):
	motion = Vector2()
	if !attack:
		if Input.is_action_pressed("down"):
			motion.y = 5
			$AnimationPlayer.play("WalkDown")
		elif Input.is_action_pressed("up"):
			motion.y = -5
			$AnimationPlayer.play("WalkUp")
		elif Input.is_action_pressed("left"):
			motion.x = -5
			$AnimationPlayer.play("WalkLeft")		
		elif Input.is_action_pressed("right"):
			motion.x = 5
			$AnimationPlayer.play("WalkRight")
		elif anim == "WalkRight" or anim == "AttackRight":
			$AnimationPlayer.play("IdleRight")
		elif anim == "WalkDown" or anim == "AttackDown":
			$AnimationPlayer.play("IdleDown")
		elif anim == "WalkLeft" or anim == "AttackLeft":
			$AnimationPlayer.play("IdleLeft")
		elif anim == "WalkUp" or anim == "AttackUp":
			$AnimationPlayer.play("IdleUp")
	if Input.is_action_pressed("attack"):
		if anim == "WalkDown" or anim == "IdleDown":
			$AnimationPlayer.play("AttackDown")
		if anim == "WalkUp" or anim == "IdleUp":
			$AnimationPlayer.play("AttackUp")
		if anim == "WalkLeft" or anim == "IdleLeft":
			$AnimationPlayer.play("AttackLeft")
		if anim == "WalkRight" or anim == "IdleRight":
			$AnimationPlayer.play("AttackRight")
		attack = true
		yield($AnimationPlayer,"animation_finished")
		attack = false
	move_and_collide(motion)

func _on_AnimationPlayer_animation_started(anim_name):
	anim = anim_name
