extends ColorRect

signal fade_finished		#kod do efekty przcyemnienia pomiędzy scenami

func fade_in():
	$AnimationPlayer.play("fade_in")#odpala efekt
	
func _on_AnimationPlayer_animation_finished(_anim_name):#daje sygnał że efekt się skończył
	emit_signal("fade_finished")
