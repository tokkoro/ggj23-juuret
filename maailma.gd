extends Node2D

onready var round_end_curtain_effect = $curtains.material

var round_time_left = 10.0
var transition = false
var transition_halfway = false

const TRANSITION_DURATION = 5.0
const ROUND_DURATION = 10.0

func is_game_paused():
	if transition:
		return true
	return false

func new_round():
	# play new round audio
	round_time_left = ROUND_DURATION
	transition = false
	round_end_curtain_effect.set_shader_param("progress", 0.0)
	print("signal: round_start")
	emit_signal("round_start")

func end_round():
	# play round end audio
	transition = true
	print("signal: round_end")
	emit_signal("round_end")

func _ready():
	new_round()
	pass

func _process(delta):
	round_time_left -= delta
	if transition:
		if not transition_halfway && round_time_left < -TRANSITION_DURATION * 0.5:
			transition_halfway = true
			print("singal: transition_halfway")
			emit_signal("transition_halfway")
		
		if round_time_left < -TRANSITION_DURATION:
			new_round()
		else:
			round_end_curtain_effect.set_shader_param("progress", -round_time_left / TRANSITION_DURATION)
	elif round_time_left < 0:
		end_round()
		
