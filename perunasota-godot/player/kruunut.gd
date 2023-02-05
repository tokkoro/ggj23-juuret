extends Node2D

var target_player = null

var crownsGfxs = [] 

func crowns(number):
	while len(crownsGfxs) < number:
		var kruunu = preload("res://player/kruunu.tscn").instance()
		kruunu.global_position = global_position
		kruunu.player = target_player
		target_player.get_node("..").add_child(kruunu)
		if len(crownsGfxs) > 0:
			kruunu.target_crown = crownsGfxs.back()
		crownsGfxs.append(kruunu)

func _ready():
	crowns(0)

func _process(delta):
	# set first position to me
	if not is_instance_valid(target_player):
		for c in crownsGfxs:
			c.queue_free()
		queue_free()
		return
	global_position = target_player.global_position + Vector2(0, -20)
	# update amount
	crowns(target_player.get_node("..").player_scores[target_player.player_number])
	# update position from root
	if len(crownsGfxs) > 0:
		crownsGfxs[0].global_position = global_position
	for c in crownsGfxs:
		c.update_position(delta)


func burn():
	for c in crownsGfxs:
		c.burn()
