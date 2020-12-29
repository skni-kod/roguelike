extends Position2D

onready var label = get_node("Label")
onready var tween = get_node("Tween")
var amount = 0
var type = ""

var velocity = Vector2(0,0)

func _ready():
	label.set_text(str(amount))
	
	match type:
		"Damage":
			label.set("custom_colors/font_color", Color("ff4d4d"))
			
	randomize()
	var side_movement= randi() % 91 - 40
	velocity = Vector2(side_movement, 25)
	
	tween.interpolate_property(self, 'scale', scale, Vector2(1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	

func _on_Tween_tween_all_completed():
	self.queue_free()

func _process(delta):
	position -= velocity * delta
