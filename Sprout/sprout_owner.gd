extends Node2D

var sprouts = []
const RADIUS = 50
var spawn_potato_count = 4

func try_pickup_sprout(pos):
	for i in range(len(sprouts)):
		print((sprouts[i].position - pos).length())
		if (sprouts[i].global_position - pos).length() < RADIUS:
			sprouts[i].queue_free()
			sprouts.erase(sprouts[i])
			print("Sprout", i)
			return true
	return false

func _process(delta):
	for i in range(spawn_potato_count):
		var grenade = preload("res://Grenade/Grenade.tscn").instance()
		grenade.position.x = -300.0 + i * 200.0 - rand_range(-100.0, 100.0)
		grenade.position.y = -300.0 + rand_range(0.0, 200.0)
		get_node("..").add_child(grenade)
		print(grenade.global_position)
	spawn_potato_count = 0
