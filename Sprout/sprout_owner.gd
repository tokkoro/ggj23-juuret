extends Node2D

onready var maailma = get_node("..")

var sprouts = []
const RADIUS = 50
var spawn_potato_count = 4

func try_pickup_sprout(pos):
	for i in range(len(sprouts)):
		if not sprouts[i].ripe:
			continue
		if (sprouts[i].global_position - pos).length() < RADIUS:
			sprouts[i].queue_free()
			sprouts.erase(sprouts[i])
			return true
	return false

func _ripen_sprouts():
	for i in range(len(sprouts) - 1, -1, -1):
		if sprouts[i].ripe:
			sprouts[i].queue_free()
			sprouts.erase(sprouts[i])
		else:
			sprouts[i].ripe = true

func _ready():
	maailma.connect("transition_halfway", self, "_ripen_sprouts")

func _process(delta):
	for i in range(spawn_potato_count):
		var grenade = preload("res://Grenade/Grenade.tscn").instance()
		grenade.position.x = -300.0 + i * 200.0 - rand_range(-100.0, 100.0)
		grenade.position.y = -100.0 + rand_range(0.0, 100.0)
		grenade.preripened = true
		get_node("..").add_child(grenade)
	spawn_potato_count = 0
