extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = Time.get_ticks_usec() / 1000000.0;
	rotation = sin(t / PI * 16) * PI * (1.0/64.0)
	scale = Vector2(
		cos(t * 4) * 0.2 + 1.0,
		cos(t * 3 + PI / 3.23) * 0.1 + 1.0
	)
