extends Node2D

onready var maailma = get_node("..")

var sprouts = []
const RADIUS = 60
var spawn_potato_count = 6

func try_pickup_sprout(pos):
	for child in get_node('..').get_children():
		if 'Grenade' in child.name:
			if (child.global_position - pos).length() < RADIUS:
				if not is_instance_valid(child.from_player):
					child.queue_free()
					return true
	return false

func burn_extra():
	for child in get_node('..').get_children():
		if 'Grenade' in child.name:
			child.burn()
	

func _remove_unused_potatoes():
	for child in get_node('..').get_children():
		if 'Grenade' in child.name:
			child.queue_free()
			print("remove left over potato")
	
	var new_potatoes = []
	for s in sprouts:
		new_potatoes.append_array(s.GetRipePositions())
		s.queue_free();
	
	# print("Generate new pottus:" + str(len(new_potatoes)))
	sprouts = []
	
	for newPos in new_potatoes:
		var grenade = preload("res://Grenade/Grenade.tscn").instance()
		grenade.position = newPos
		grenade.apply_central_impulse(Vector2(0, 100 + randf()*100))
		get_node("..").add_child(grenade)
	if len(new_potatoes) == 0:
		var y = maailma.get_latest_terrain_y()
		for i in range(4):
			var grenade = preload("res://Grenade/Grenade.tscn").instance()
			grenade.position.x = rand_range(-450.0, 450.0)
			grenade.position.y = y
			get_node("..").add_child(grenade)

func _ready():
	maailma.connect("transition_halfway", self, "_remove_unused_potatoes")

func _process(delta):
	for i in range(spawn_potato_count):
		var grenade = preload("res://Grenade/Grenade.tscn").instance()
		grenade.position.x = rand_range(-450.0, 450.0)
		grenade.position.y = rand_range(-100.0, 50.0)
		get_node("..").add_child(grenade)
	spawn_potato_count = 0
