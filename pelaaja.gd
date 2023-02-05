extends RigidBody2D

var player_number = 0
var dead = 0

var x_velocity = 0.0
var x_last_tick = 0.0
var im_hit_no_collision_timer = Timer.new();

var color: Color
var black = Color(0,0,0,1)

var burning = false
var burning_duration = 0

var kruunut

func _ready():
	if player_number == 0:
		color = Color(1.0, 0.5, 0.5)
	elif player_number == 1:
		color = Color(0.5, 1.0, 0.5)
	elif player_number == 2:
		color = Color(0.5, 0.5, 1.0)
	else:
		color = Color(0.9, 0.9, 0.5)
	$Sprite.modulate = color
	
	kruunut = preload("res://player/kruunut.tscn").instance()
	kruunut.target_player = self
	get_node("..").add_child(kruunut)

func _physics_process(delta):
	pass

func die():
	dead = true
	apply_central_impulse(Vector2(rand_range(-30, 30), rand_range(-1500, -800)))

func burn():
	# print("BURN p " + name)
	burning = true
	burning_duration = 0
	kruunut.burn()
	for o in get_node('./face').get_children():
		if "eye" in o.name:
			o.burn()
	
func _process(delta):
	if burning:
		burning_duration += delta
		var c = color.linear_interpolate(black, clamp(burning_duration, 0, 1))
		$Sprite.modulate = c
