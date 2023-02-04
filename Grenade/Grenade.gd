extends RigidBody2D

var from_player = null
var spawn_time = 0
var preripened = false

func _ready():
	contact_monitor = true
	contacts_reported = 5
	connect("body_entered", self, "_body_entered_asdf")
	spawn_time = Time.get_ticks_msec()

func _body_entered_asdf(node: PhysicsBody2D):
	var is_ground = node.get_collision_mask_bit(10)

	if is_ground:
		# istutu
		var sprout = preload("res://Sprout/potato_sprout.tscn").instance()
		sprout.position = position
		sprout.ripe = preripened
		var sprout_owner = get_node("../sprout_owner")
		sprout_owner.add_child(sprout)
		sprout_owner.sprouts.append(sprout)
		print("Maa-istutun")
		queue_free()
	elif "Player" in node.get_name():
		if from_player == node and Time.get_ticks_msec() - spawn_time < 200:
			print("Älä lyö sua!")
			return
		# kill audio
		print("Pelaaja-kuale")
		#aosdfiojajiopdsf
		queue_free()
		
		
