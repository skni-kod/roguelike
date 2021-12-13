extends StaticBody2D

var gracz
var k = 0

func _ready():
	$AnimationPlayer.play("idle")
	set_process(false)

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		get_node("E").visible = true
		gracz = body
		set_process(true)
		k = 1

func _on_Area2D2_body_entered(body):
	if body.name == "Player":
		get_node("E").visible = true
		gracz = body
		set_process(true)
		k = 2

func _on_Area2D2_body_exited(body):
	if body.name == "Player":
		get_node("E").visible = false
		gracz = null
		set_process(false)

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		get_node("E").visible = false
		set_process(false)

func _process(_delta):
	if Input.is_action_pressed("pick") and gracz:
		if k == 1:
			if gracz.coins >= 20:
				gracz.coins -= 20
				gracz.level.get_node("UI/Coins").text = "Coins:"+str(gracz.coins)
				var potion_name = gracz.potion.get_node("PotionNameHolder").text #zmienna przechowująca nazwe potka bez oznaczenia kopii np 50%Potion
				var potion_tmp = gracz.potion.name #zmienna przechowująca rzeczywistą nazwe danego potka w scenie np 50%Potion2
				if gracz.potions[1]=="Empty": #jeżeli niema potka na slocie 1 to:
					gracz.swap_potion(1,potion_name) #ustawienie na slot 1 potka przy ktorym stoi gracz
				elif gracz.potions[2]=="Empty": #jeżeli niema potka na slocie 2 to:
					gracz.swap_potion(2,potion_name) #ustawienie na slot 2 potka przy ktorym stoi gracz
				else:
					gracz.potions_amount[gracz.potions[1]] = 0 #wyzerowanie ilości potków aktualnego potka na miejscu 1
					gracz.swap_potion(1,potion_name) #ustawienie na slot 1 potka przy ktorym stoi gracz
				if "50%Potion" in potion_name:
					gracz.potions_amount["50%Potion"]+=1 #zwieksza ilość potek 50% o 1
				elif "100%Potion" in potion_name:
					gracz.potions_amount["100%Potion"]+=1#zwieksza ilość potek 100% o 1
				elif "20healthPotion" in potion_name:
					gracz.potions_amount["20healthPotion"]+=1 #zwieksza ilość potek 20hp o 1
				elif "60healthPotion" in potion_name:
					gracz.potions_amount["60healthPotion"]+=1 #zwieksza ilość potek 60hp o 1
				gracz.potion = null #wyzerowanie zmiennej potion, czyli gracz niestoi już przy potku
				gracz.level.get_node(potion_tmp).queue_free() #usuniecie podniesionego potka z sceny
				gracz.UpdatePotions()
		else:
			if gracz.coins >= 50:
				gracz.coins -= 50
				gracz.level.get_node("UI/Coins").text = "Coins:" + str(gracz.coins)
				if gracz.weapons[2] == "Empty":
					gracz.swap_weapon(2,gracz.weaponToTake)
				else:
					if gracz.current_weapon != null:
						gracz.swap_weapon(gracz.current_weapon, gracz.weaponToTake)
