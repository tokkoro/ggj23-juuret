extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed = 2.0
var target_terraingen: Terraingen = null
var t_0 = 0
var t_arrive = 0
var p_0 = Vector2(0, 0)
export var transition_curve: Curve

# Called when the node enters the scene tree for the first time.
func _ready():
	rotating = true

func start_move_to_next_round(terraingen: Terraingen, arrive_time: float):
	t_0 = Time.get_ticks_usec() / 1000000.0
	t_arrive = arrive_time
	p_0 = position
	target_terraingen = terraingen;
	print("Now: ", t_0, "; arri: ", arrive_time, "; diff ", arrive_time - t_0)
	pass

func transition(delta: float):
	if target_terraingen == null:
		return
	
	var time_now = Time.get_ticks_usec() / 1000000.0
	var t = (time_now - t_0) / (t_arrive - t_0)
	var d = transition_curve.interpolate(t);
	
	# var diff = (target_terraingen.position - position) * delta * speed
	position = p_0 + (target_terraingen.position - p_0) * d;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	transition(delta)
	
	# rotation = randf() * PI
