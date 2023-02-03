extends Node2D

onready var sprite = $Sprite
onready var parent_sprite = get_node("../Sprite")
onready var parent = get_node("..")

var throw_force = 0.0
var throw_held = false
var has_potato = false

func pickup_potato():
	var is_potato_nearby = int(Time.get_ticks_msec()) % 2000 < 1000 # TODO: Implement
	if is_potato_nearby:
		# TODO: Remove potato from ground
		has_potato = true

func launch_potato(facing, force):
	has_potato = false
	var bomb = preload("res://Grenade/Grenade.tscn").instance()
	var spawn_offset = Vector2(0, 0)
	spawn_offset.x *= facing
	bomb.position = sprite.global_position + spawn_offset
	bomb.from_player = parent
	var x_force_multiplier = 100.0
	var y_force_multiplier = 100.0
	bomb.gravity_scale = 2
	bomb.apply_central_impulse(Vector2(facing * (0.3 + force) * x_force_multiplier, -1 * (0.5 + force * 0.5) * y_force_multiplier))
	get_node("../..").add_child(bomb)

func _process(delta):
	throw_held = Input.is_action_pressed("throw")
	if Input.is_action_just_pressed("throw"):
		pickup_potato()
		if has_potato:
			# loading sound effect start
			pass
	if Input.is_action_just_released("throw"):
		# loading sound effect stop
		# throw sound effect
		pass

func _physics_process(delta):
	var facing = 1.0
	if parent_sprite.flip_h:
		facing = -1.0
	if not has_potato:
		throw_force = 0.0
	elif throw_held:
		throw_force += delta
	elif throw_force > 0:
		launch_potato(facing, throw_force)
		throw_force = 0
	
	sprite.rotation_degrees = -90 + 50 * facing
	sprite.position.x = 10 * facing
	sprite.flip_v = facing < 0
	if throw_force <= 0:
		sprite.scale.x = 0
	else:
		sprite.scale.x = throw_force
