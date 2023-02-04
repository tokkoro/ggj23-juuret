extends Node2D

onready var power_indicator = $PowerIndicator
onready var parent_sprite = get_node("../Sprite")
onready var parent = get_node("..")
onready var sprout_owner = get_node("../../sprout_owner")
onready var maailma = get_node("../..")

var throw_force = 0.0
var throw_held = false
var throw_was_held = false
var has_potato = false
var flip = false


func _ready():
	power_indicator.scale.x = 0;
	
func pickup_potato():
	var is_potato_nearby = sprout_owner.try_pickup_sprout(global_position)
	if is_potato_nearby:
		has_potato = true
		maailma.audio.play("lift")

func launch_potato(facing, force):
	has_potato = false
	var bomb = preload("res://Grenade/Grenade.tscn").instance()
	var spawn_offset = Vector2(10, -10)
	spawn_offset.x *= facing
	bomb.position = global_position + spawn_offset
	bomb.from_player = parent
	bomb.from_player_number = parent.player_number
	var x_force_multiplier = 100.0
	var y_force_multiplier = 100.0
	bomb.apply_central_impulse(Vector2(facing * (0.3 + force) * x_force_multiplier, -1 * (0.7 + force * 0.5) * y_force_multiplier))
	get_node("../..").add_child(bomb)
	maailma.audio.play("throw")

func _process(delta):
	if throw_held and not throw_was_held:
		pickup_potato()
		if has_potato:
			# loading sound effect start
			pass
	if throw_was_held and not throw_held:
		# loading sound effect stop
		# throw sound effect
		pass
	throw_was_held = throw_held

func _physics_process(delta):
	var facing = 1.0
	if flip:
		facing = -1.0
	if not has_potato:
		throw_force = 0.0
	elif throw_held:
		throw_force += delta * 10
	elif throw_force > 0:
		launch_potato(facing, throw_force)
		throw_force = 0
	
	if throw_force <= 0:
		power_indicator.scale.x = 0
	else:
		power_indicator.scale.x = facing * throw_force * 0.3
