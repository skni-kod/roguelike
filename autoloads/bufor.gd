extends Node
# ==================================================
# globalny skrypt, który pozwala przerzucać wartości
# po ponowym wczytaniu sceny (po walce z bossem)
# ==================================================
var coins = null
var poziom = 0 # numer poziomu
var weapons = null
var first_weapon_stats = null
var second_weapon_stats = null
var equipped = null
var potions = null
var potions_amount = null

# przechowuje informacje o wyglądzie gracza
var tekstury = [0, 0, 0]
