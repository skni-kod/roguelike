# Laser.gd
extends RayCast2D
# UWAGA WORK IN PROGRESS
# NIE DZIAŁA TAK JAK POWINNO
# UWAGA WORK IN PROGRESS

var player_Pos = Vector2.ZERO
onready var origin = self.position
var dps = 1

var is_casting := false setget set_is_casting

var body = null
var attack = false

func _ready():
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO
	$Lifetime.start()
	self.is_casting = true
	rotation = (player_Pos - origin).normalized().angle()


func _physics_process(delta):
	var cast_point := cast_to
	force_raycast_update()
	
	$CollisionParticles.emitting = is_colliding()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$CollisionParticles.global_rotation = get_collision_normal().angle()
		$CollisionParticles.position = cast_point
		
		body = self.get_collider()
		if body.name == "Player":
			body.take_dmg(get_tree().get_root().find_node("Big Devil", true, false))
		
	$Line2D.points[1] = cast_point
	$LaserParticles.position = cast_point * 0.5
	$LaserParticles.process_material.emission_box_extents.x = cast_point.length() * 0.5


func set_is_casting(cast: bool):
	is_casting = cast
	
	$LaserParticles.emitting = is_casting
	$CastingParticles.emitting = is_casting
	if is_casting:
		appear()
	else:
		$CollisionParticles.emitting = false
		disappear()
	set_physics_process(is_casting)


func appear():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 10.0, 0.2)
	$Tween.start()
	

func disappear():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 0.0, 0.2)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

#func _on_Atak_body_entered(body):
#	if body.name == "Player":
#		body.take_dmg(self)


func _on_Lifetime_timeout():
	disappear()

