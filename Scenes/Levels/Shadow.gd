extends CanvasModulate

var maksPoziom = 24
var kolor1 = [0.05,0,0.10]
var kolor2 = [1,1,1]

func _ready():
	var p = min(1, Bufor.POZIOM/maksPoziom)
	var cz = kolor1[0]*(p) + kolor2[0] * (1 - p) / 1.5
	var zi = kolor1[1]*(p) + kolor2[1] * (1 - p) / 1.5
	var nb = kolor1[2]*(p) + kolor2[2] * (1 - p) / 1.5
	color = Color(cz, zi, nb)
