extends RigidBody2D

var from_player = null

func _ready():
	print("test")
	contact_monitor = true
	contacts_reported = 5
	connect("body_entered", self, "_body_entered_asdf")
	pass # Replace with function body.

func _body_entered_asdf(node):
	if "terrain" in node.get_name() or "World" in node.get_name():
		# istutu
		print("Maa-istutun")
		pass
	elif "Player" in node.get_name():
		# tapa
		if from_player == node:
			print("Älä lyö sua!")
		print("Pelaaja-kuale")
		pass
		
