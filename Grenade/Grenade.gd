extends RigidBody2D

var from_player = null
var spawn_time = 0

func _ready():
	print("test")
	contact_monitor = true
	contacts_reported = 5
	connect("body_entered", self, "_body_entered_asdf")
	spawn_time = Time.get_ticks_msec()

func _body_entered_asdf(node):
	if "terrain" in node.get_name() or "World" in node.get_name():
		# istutu
		var sprout = preload("res://Sprout/potato_sprout.tscn").instance()
		sprout.position = position
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
		queue_free()
		
		
