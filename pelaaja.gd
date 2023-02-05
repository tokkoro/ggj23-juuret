extends RigidBody2D

var player_number = 0
var dead = 0

var x_velocity = 0.0
var x_last_tick = 0.0
var im_hit_no_collision_timer = Timer.new();

func _ready():
	if player_number == 0:
		$Sprite.modulate = Color(1.0, 0.5, 0.5)
	elif player_number == 1:
		$Sprite.modulate = Color(0.5, 1.0, 0.5)
	elif player_number == 2:
		$Sprite.modulate = Color(0.5, 0.5, 1.0)
	else:
		$Sprite.modulate = Color(0.9, 0.9, 0.5)
	
	var crown = preload("res://player/kruunut.tscn").instance()
	crown.target_player = self
	get_node("..").add_child(crown)
	print("p ready", player_number)

func _physics_process(delta):
	pass
	
func die():
	print("I die!", player_number)
	dead = true
	apply_central_impulse(Vector2(rand_range(-30, 30), rand_range(-1500, -800)))
