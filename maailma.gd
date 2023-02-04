extends Node2D

onready var round_end_curtain_effect = $curtains.material

onready var input = $input

signal round_start
signal round_end
signal transition_halfway

var round_time_left = 10.0
var transition = false
var transition_halfway = false

const TRANSITION_DURATION = 5.0
const ROUND_DURATION = 3.0

var players = []
var player_spawn_points = [Vector2(0,-100), Vector2(100,-100), Vector2(300,-100), Vector2(400,-100)]

func is_game_paused():
	if transition:
		return true
	return false

func new_round():
	# play new round audio
	round_time_left = ROUND_DURATION
	transition = false
	round_end_curtain_effect.set_shader_param("progress", 0.0)
	for player_number in range(4):
		var player = preload("res://player.tscn").instance()
		player.player_number = player_number
		player.position = player_spawn_points[player_number]
		
		players.append(player)
		add_child(player)
	print("signal: round_start")
	emit_signal("round_start")

func end_round():
	# play round end audio
	transition = true
	transition_halfway = false
	print("signal: round_end")
	emit_signal("round_end")

func _ready():
	new_round()

func _physics_process(delta):
	for player_number in range(len(players)):
		var left = Input.is_action_pressed(input.get_input_string("player_left_", player_number))
		var right = Input.is_action_pressed(input.get_input_string("player_right_", player_number))
		var throw = Input.is_action_pressed(input.get_input_string("player_throw_", player_number))
		var x = 0.0
		if left:
			x += -1.0
		if right:
			x += 1.0
		players[player_number].get_node("GrenadeThrow").throw_held = throw
		players[player_number].add_central_force(Vector2(x * 100.0, 0))

func _process(delta):
	round_time_left -= delta
	if transition:
		if not transition_halfway && round_time_left < -TRANSITION_DURATION * 0.5:
			transition_halfway = true
			for i in range(len(players)):
				player_spawn_points[i].x = players[i].position.x
				players[i].queue_free()
			players.clear()
			print("singal: transition_halfway")
			emit_signal("transition_halfway")
		
		if round_time_left < -TRANSITION_DURATION:
			new_round()
		else:
			round_end_curtain_effect.set_shader_param("progress", -round_time_left / TRANSITION_DURATION)
	elif round_time_left < 0:
		end_round()
		
