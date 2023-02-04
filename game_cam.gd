extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var target_terraingen: Terraingen = null

# Called when the node enters the scene tree for the first time.
func _ready():
	rotating = true

func start_move_to_next_round(terraingen: Terraingen):
	target_terraingen = terraingen;
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.linear_interpolate(target_terraingen.position, delta)
	
	# rotation = randf() * PI
