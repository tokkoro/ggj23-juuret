extends Sprite


var color: Color = Color(1,1,1,1)
var black = Color(0,0,0,0)

var burning = false
var burning_duration = 0

func burn():
	# print("BURN pot " + name)
	burning = true
	burning_duration = 0
	
func _process(delta):
	if burning:
		burning_duration += delta
		var c = color.linear_interpolate(black, clamp(burning_duration, 0, 1))
		modulate = c

