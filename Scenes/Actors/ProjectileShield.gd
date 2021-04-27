extends Area2D

func _on_ProjectileShield_body_entered(body):
	if(body.collision_layer == 8):
		body.queue_free()
