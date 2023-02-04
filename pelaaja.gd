extends RigidBody2D

var player_number = 0
var dead = 0

func _ready():
	print("p", player_number)

func _physics_process(delta):
	
	pass
	
func die():
	print("I'm die!")
	dead = true
