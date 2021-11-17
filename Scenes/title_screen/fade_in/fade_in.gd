extends ColorRect

signal fade_finished		#kod do efekty przcyemnienia pomiędzy scenami

func fade_in():
	get_parent().get_node("Lights/Lamp_2").visible = false
	$AnimationPlayer.play("fade_in")#odpala efekt
	
func _on_AnimationPlayer_animation_finished(anim_name):#daje sygnał że efekt się skończył
	emit_signal("fade_finished")
