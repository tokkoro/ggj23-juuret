extends Node2D

var sprouts = []
const RADIUS = 50

func try_pickup_sprout(pos):
	for i in range(len(sprouts)):
		if (sprouts[i].position - pos).length() < RADIUS:
			sprouts.erase(sprouts[i])
			sprouts[i].queue_free()
			

func _ready():
	pass
