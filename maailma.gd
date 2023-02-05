extends Node2D

onready var round_end_curtain_effect = $game_cam.get_node("flames").material
onready var audio = $game_cam.get_node("audio")
onready var input = $input

signal round_start
signal round_end
signal transition_halfway

var round_time_left = 10.0
var transition = false
var transition_halfway = false
var game_running = true
var wait_for_first_sprout = true

const TRANSITION_DURATION = 2.0
const ROUND_DURATION = 10.0

const reactivate_ceiling_time = 7.0
var reactivated_ceiling_collider = false

var players = []
var player_spawn_points = [Vector2(0,-100), Vector2(100,-100), Vector2(300,-100), Vector2(400,-100)]
var player_scores = [0,0,0,0]
var round_terrains = []

func is_game_paused():
	if transition:
		return true
	return false
	
func new_terrain():
	var round_index = round_terrains.size()
	var terraingen = preload("res://terrain/terraingen-node.tscn").instance()
	terraingen.name = "terraingen_round_" + str(round_index)
	terraingen.position.y = round_index * terraingen.get_terrain_whole_height();
	add_child(terraingen)
	round_terrains.push_back(terraingen)
	
	$game_cam.start_move_to_next_round(terraingen, Time.get_ticks_usec() / 1000000.0 + TRANSITION_DURATION)

func new_round():
	# play new round audio
	round_time_left = ROUND_DURATION
	transition = false
	round_end_curtain_effect.set_shader_param("progress", 1.0)
	
	for player_number in range(4):
		var player = preload("res://player/player.tscn").instance()
		player.player_number = player_number
		player.position = Vector2(player_spawn_points[player_number].x, round_terrains.back().position.y)

		player.name = "player_" + str(player_number)

		player.x_last_tick = player.position.x;

		players.append(player)
		add_child(player)
		
	print("signal: round_start")
	emit_signal("round_start")

func end_round():
	# play round end audio
	audio.play("flames")
	audio.play("death")
	round_end_curtain_effect.set_shader_param("progress", 1.0)
	transition = true
	transition_halfway = false
	for player_number in range(len(players)):
		players[player_number].die()
		players[player_number].burn()
	get_node("./sprout_owner").burn_extra()
	
	new_terrain()
	
	print("signal: round_end")
	emit_signal("round_end")

func _ready():
	player_scores = [0,0,0,0]
	new_terrain()
	new_round()

func _physics_process(delta):
	for player_number in range(len(players)):
		var player_sprite = players[player_number].get_node("Sprite");
		var left = Input.is_action_pressed(input.get_input_string("player_left_", player_number))
		var right = Input.is_action_pressed(input.get_input_string("player_right_", player_number))
		var throw = Input.is_action_pressed(input.get_input_string("player_throw_", player_number))
		if players[player_number].dead:
			left = false
			right = false
			throw = false
			player_sprite.rotation_degrees = 45
			
		var x = 0.0
		var current_player = players[player_number];
		if left:
			x += -1.0
			player_sprite.rotation_degrees = 135
			current_player.get_node("GrenadeThrow").flip = true
		if right:
			x += 1.0
			player_sprite.rotation_degrees = -45
			current_player.get_node("GrenadeThrow").flip = false
			
		current_player.get_node("GrenadeThrow").throw_held = throw
		var y_impulse = 0
		var raycast_on_floor = current_player.get_node("FloorCast").is_colliding()||current_player.get_node("FloorCast2").is_colliding() 

		if x != 0 && raycast_on_floor:
			y_impulse = -45
		current_player.apply_central_impulse(Vector2(x * 30.0, y_impulse))
	
		#raycast to see if enemy at top of player
		var top_raycast = current_player.get_node("TopCast");
		var is_someone_at_top = top_raycast.is_colliding();
		
		if is_someone_at_top:
			var enemy : RigidBody2D = top_raycast.get_collider();
			var flipped = 1
			var still = enemy.dead or abs(enemy.linear_velocity.x) < 1
			if (still and right) or (not still and enemy.get_node("GrenadeThrow").flip):
				flipped = -1
			enemy.apply_central_impulse(Vector2(flipped * 320, -300.0))
			enemy.im_hit_no_collision_timer.connect("timeout",self,"reset_collision_mask")
			enemy.im_hit_no_collision_timer.wait_time = 0.3
			enemy.im_hit_no_collision_timer.one_shot = true
			enemy.im_hit_no_collision_timer.start()
			enemy.set_collision_layer_bit(3, false) 
	
	
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


func score(player_number):
	player_scores[player_number] += 1
	audio.play("death")
	audio.play("thud")

func reset_collision_mask(var enemy):
	enemy.set_collision_layer_bit(3, true);

func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		
	if not game_running:
		return
	if not wait_for_first_sprout and not audio.bgm.playing:
		audio.bgm.play()
	if not wait_for_first_sprout:
		round_time_left -= delta
	if transition:
		if not transition_halfway && round_time_left < -TRANSITION_DURATION * 0.5:
			transition_halfway = true
			reactivated_ceiling_collider = false
			for i in range(len(players)):
				player_spawn_points[i].x = players[i].position.x
				players[i].queue_free()
			players.clear()
			# free potatoes
			for t in round_terrains:
				if t != round_terrains.back():
					t.stop_colliding()
			print("singal: transition_halfway")
			emit_signal("transition_halfway")
		
		if round_time_left < -TRANSITION_DURATION:
			new_round()
		else:
			var t = sin(lerp(0.0, 3.14, -round_time_left / TRANSITION_DURATION))
			var progress = 1 - t
			round_end_curtain_effect.set_shader_param("progress", progress)
	elif round_time_left < 0:
		if round_terrains.size() <= 11:
			end_round()
		else:
			end_game()
	
	if (not reactivated_ceiling_collider) and (round_time_left < reactivate_ceiling_time):
		print("Activate ceiling")
		reactivated_ceiling_collider = true
		#round_terrains.back().start_colliding()

func end_game():
	print("game over!")
	game_running = false

func get_latest_terrain_y():
	return round_terrains.back().position.y
		
func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
