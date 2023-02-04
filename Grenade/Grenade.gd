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
		var sprout = preload("res://juurtuva_pottu/Pottu.tscn").instance()
		sprout.SetStartPosition(position);
		sprout.ripe = preripened
		var sprout_owner = get_node("../sprout_owner")
		sprout_owner.add_child(sprout)
		sprout_owner.sprouts.append(sprout)
		queue_free()
	elif "player" in node.name:
		if from_player == node and Time.get_ticks_msec() - spawn_time < 200:
			print("Älä lyö sua!")
			return
		# kill audio
		if is_instance_valid(from_player):
			print("Player " + node.name + " hit by " + from_player.name)
			node.die()
		else:
			print("This pottu was not from anyone")
		queue_free()
