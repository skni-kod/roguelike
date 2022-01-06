# Tarcza dla przeciwnikow blokujaca pociski gracza
extends Area2D

# Funkcja wywolywana gdy pocisk wejdzie w obszar
func _on_EnemyProjectileShield_body_entered(body):
	if(body.collision_layer == 8):	# Jesli jest to pocisk gracza
		body.queue_free()	# Usun pocisk gracza
