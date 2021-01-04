extends Node2D

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
export var attack_range = 15
onready var timer = $Timer
onready var player_node := get_tree().get_root().find_node("Player", true, false)
var damage = 1
var attack_speed = 0.0

func _ready():
	player_node.connect("attacked", self, "_on_Player_attacked")

func _physics_process(delta):
	if !attack:
		mouse_position = get_local_mouse_position()
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * 0.1
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * 0.1
		else:
			rotation += mouse_position.angle() * 0.1
		if rotation < -PI/2 or rotation > PI/2:
			$SwordSprite.scale.y = -1
		else:
			$SwordSprite.scale.y = 1

func _on_Player_attacked():
	if !attack:
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		timer.start()

func _on_Timer_timeout():
	attack_speed += 0.01
	if attack_speed <= 0.15:
		position += attack_vector * (0.01/0.15)
		if rotation < -PI/2 or rotation > PI/2:
			$SwordSprite.rotation_degrees += -90 * (0.01/0.15)
		else:
			$SwordSprite.rotation_degrees += 90 * (0.01/0.15)
		
	elif attack_speed > 0.3:
		position -= attack_vector
		$SwordSprite.rotation_degrees = 0
		$AttackCollision.disabled = true
		attack = false
		attack_speed = 0
		timer.stop()

func change_weapon(texture):
	$SwordSprite.texture = texture

func _on_Axe_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
