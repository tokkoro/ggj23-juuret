extends RigidBody2D

var player_number = 0
var dead = 0

var x_velocity = 0.0
var x_last_tick = 0.0
var im_hit_no_collision_timer = Timer.new();
func _ready():
	print("p", player_number)

func _physics_process(delta):
	
	pass
	
func die():
	print("I'm die!")
	dead = true
