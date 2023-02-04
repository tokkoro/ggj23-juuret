extends Node2D

onready var round_end_curtain_effect = $flames.material
onready var audio = $game_cam.get_node("audio")
onready var input = $input

signal round_start
signal round_end
signal transition_halfway

var round_time_left = 10.0
var transition = false
var transition_halfway = false

const TRANSITION_DURATION = 2.0
const ROUND_DURATION = 8.0

var players = []
var player_spawn_points = [Vector2(0,-100), Vector2(100,-100), Vector2(300,-100), Vector2(400,-100)]
var round_index = -1;

func is_game_paused():
	if transition:
		return true
	return false

func new_round():
	round_index += 1
	# play new round audio
	round_time_left = ROUND_DURATION
	transition = false
	round_end_curtain_effect.set_shader_param("progress", 1.0)
	for player_number in range(4):
		var player = preload("res://player.tscn").instance()
		player.player_number = player_number
		player.position = player_spawn_points[player_number]

		player.name = "player_" + str(player_number)

		player.x_last_tick = player.position.x;

		players.append(player)
		add_child(player)
		
	var terraingen = preload("res://terrain/terraingen-node.tscn").instance()
	terraingen.name = "terraingen_round_" + str(round_index)
	terraingen.position.y += round_index * terraingen.get_terrain_whole_height()
	add_child(terraingen)
	
	$game_cam.start_move_to_next_round(terraingen)
	
	print("signal: round_start")
	emit_signal("round_start")

func end_round():
	# play round end audio
	round_end_curtain_effect.set_shader_param("progress", 0.0)
	transition = true
	transition_halfway = false
	for player_number in range(len(players)):
		players[player_number].die()
		
	print("signal: round_end")
	emit_signal("round_end")

func _ready():
	new_round()

func _physics_process(delta):
	for player_number in range(len(players)):
		var left = Input.is_action_pressed(input.get_input_string("player_left_", player_number))
		var right = Input.is_action_pressed(input.get_input_string("player_right_", player_number))
		var throw = Input.is_action_pressed(input.get_input_string("player_throw_", player_number))
		if players[player_number].dead:
			left = false
			right = false
			throw = false
			players[player_number].get_node("Sprite").flip_v = true
			
		var x = 0.0
		var current_player = players[player_number];
		if left:
			x += -1.0
			current_player.get_node("Sprite").flip_h = true
		if right:
			x += 1.0
			current_player.get_node("Sprite").flip_h = false;
			
		current_player.get_node("GrenadeThrow").throw_held = throw
		var y_impulse = 0
		var raycast_on_floor = current_player.get_node("FloorCast").is_colliding() 
		if x != 0 && raycast_on_floor:
			y_impulse = -45
		current_player.apply_central_impulse(Vector2(x * 30.0, y_impulse))
	
		#raycast to see if there is enemy in front that can be punched out of the way	
		var enemy_raycast = current_player.get_node("EnemyCast");
		var colliding_enemy = enemy_raycast.is_colliding();
		
		var diff = current_player.position.x - current_player.x_last_tick;
		current_player.x_velocity = sqrt(diff*diff)
		
		if colliding_enemy:
			var enemy = enemy_raycast.get_collider()
			if(enemy.x_velocity < current_player.x_velocity):
				enemy.apply_central_impulse(Vector2(x * 80, -600.0))
				enemy.im_hit_no_collision_timer.connect("timeout",self,"reset_collision_mask")
				enemy.im_hit_no_collision_timer.wait_time = 0.3
				enemy.im_hit_no_collision_timer.one_shot = true
				enemy.im_hit_no_collision_timer.start()
				enemy.set_collision_layer_bit(3, false) 
			
		current_player.x_last_tick = current_player.position.x;
		enemy_raycast.cast_to.x = x * 40;
		current_player.get_node("FloorCast").cast_to.x = x * 35;
			
func reset_collision_mask(var enemy):
	enemy.set_collision_layer_bit(3, true);

func _process(delta):
	if round_time_left >= ROUND_DURATION and not audio.bgm.playing:
		audio.bgm.play()
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
		if round_index < 5:
			end_round()
		else:
			end_game()

func end_game():
	print("game over!")
		
