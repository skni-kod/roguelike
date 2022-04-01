extends Area2D

signal Cleared() #Fms

func _on_Enemies_Cleared() -> void:
	print("reeeeeadasdwadsa")
	emit_signal("Cleared")
