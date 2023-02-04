extends Node2D

func crowns(number):
	for i in range(number):
		for child in get_children():
			if str(i) in child.name:
				child.visible = true
	for i in range(number, get_child_count()):
		for child in get_children():
			if str(i) in child.name:
				child.visible = false
	

func _ready():
	crowns(0)

func _process(delta):
	crowns(get_parent().get_node("..").player_scores[get_parent().player_number]) 
