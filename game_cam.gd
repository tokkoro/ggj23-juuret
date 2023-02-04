extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed = 2.0
var target_terraingen: Terraingen = null

# Called when the node enters the scene tree for the first time.
func _ready():
	rotating = true

func start_move_to_next_round(terraingen: Terraingen, arrive_time: float):
	print("Now: ", Time.get_ticks_msec(), "; arri: ", arrive_time)
	target_terraingen = terraingen;
	pass

func transition(delta: float):
	if target_terraingen == null:
		return
	
	var diff = (target_terraingen.position - position) * delta * speed
	position += diff;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	transition(delta)
	
	# rotation = randf() * PI
