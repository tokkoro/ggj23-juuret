extends RigidBody2D

var from_player = null
var from_player_number = 0
var spawn_time = 0

func _ready():
	contact_monitor = true
	contacts_reported = 5
	connect("body_entered", self, "_body_entered_asdf")
	spawn_time = Time.get_ticks_msec()

func _body_entered_asdf(node: PhysicsBody2D):
	var is_ground = node.get_collision_mask_bit(10)
	if not is_instance_valid(from_player):
		return
	if is_ground:
		# istutu
		var sprout = preload("res://juurtuva_pottu/Pottu.tscn").instance()
		sprout.SetStartPosition(position);
		var sprout_owner = get_node("../sprout_owner")
		sprout_owner.add_child(sprout)
		sprout_owner.sprouts.append(sprout)
		get_node("..").audio.play("thud")
		get_node('..').wait_for_first_sprout = false
		queue_free()
	elif "player" in node.name:
		if from_player == node and Time.get_ticks_msec() - spawn_time < 200:
			print("Älä lyö sua!")
			return
		# kill audio
		if is_instance_valid(from_player):
			print("Player " + node.name + " hit by " + from_player.name)
			node.die()
			get_node("..").score(from_player_number)
		else:
			print("This pottu was not from anyone")
		queue_free()
