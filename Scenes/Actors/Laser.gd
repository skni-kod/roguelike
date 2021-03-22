# Laser.gd
extends RayCast2D

onready var statusEffect = get_node("../UI/StatusBar")

var player_Pos = Vector2.ZERO
onready var origin = self.position
var dmg = 1

var is_casting := false setget set_is_casting # zmienna warunkująca czy laser jest emitowany, := to przypisanie typu do zmiennej, is_casting to bool setget set_is_casting - set_is_casting zostaje wywołana moment zanim is_casting zostanie zmieniona, decyduje co zrobić z is_casting

var body = null
var attack = false

func _ready():
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO
	$Lifetime.start()
	self.is_casting = true

	rotation = (player_Pos - origin).normalized().angle()

func _physics_process(delta):
	var cast_point := cast_to # przypisanie z typem cast_point do miejsca do którego powinien zostać wyemitowany laser
	force_raycast_update() # raycast zostaje zaktualizowany
	
	$CollisionParticles.emitting = is_colliding() # CollisionParticles zostają emitowane gdy laser na coś natrafi
	
	if is_colliding():
		cast_point = to_local(get_collision_point()) # znajduje punkt kolizji i zamienia go na lokalną pozycję
		$CollisionParticles.global_rotation = get_collision_normal().angle() # ustawienie globalnej rotacji CollisionParticles wobec kąta normalnego kolizji
		$CollisionParticles.position = cast_point # pozycja CollisionParticles to punkt, do którego zostają wyemitowane
		
		body = self.get_collider() # body to pierwsze ciało z którym skoliduje ray/laser
		if body.name == "Player":
			body.take_dmg(dmg)
		
	$Line2D.points[1] = cast_point # punkt nr 1 $Line2D zostaje ustawiony jako cast_point
	$LaserParticles.position = cast_point * 0.5 # pozycja LaserParticles zostaje ustawiona w połowie długości do cast_point
	$LaserParticles.process_material.emission_box_extents.x = cast_point.length() * 0.5 # LaserParticles emitują się na całej długości lasera


func set_is_casting(cast: bool):
	is_casting = cast # is_casting zostaje przypisana zmienna boolowa cast
	
	$LaserParticles.emitting = is_casting # widoczność LaserParticles zgodnie z is_casting
	$CastingParticles.emitting = is_casting # widoczność CastingParticles zgodnie z is_casting
	if is_casting:
		appear() # funkcja pojawiania się lasera
	else:
		$CollisionParticles.emitting = false # CastingParticles off
		disappear() #funkcja znikania lasera
	set_physics_process(is_casting) # physics_process zostaje włączony/wyłączony zgodnie z is_casting


func appear():
	$Tween.stop_all() # zatrzymuje wszystkie działania Tweena
	$Tween.interpolate_property($Line2D, "width", 0, 10.0, 0.2) # włącza pojawianie się lasera
	$Tween.start() # startuje Tweena


func disappear():
	$Tween.stop_all() # zatrzymuje wszystkie działania Tweena
	$Tween.interpolate_property($Line2D, "width", 0, 0.0, 0.2)# włącza znikanie lasera
	$Tween.start() # startuje Tweena
	yield($Tween, "tween_all_completed") # czeka aż Tween skończy pracę
	queue_free() # usuwa instancję Lasera


func _on_Lifetime_timeout():
	disappear()
