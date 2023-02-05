extends Node2D

onready var bgm : AudioStreamPlayer2D = $bgm
onready var victory_musa : AudioStreamPlayer2D = $victory_musa

func play(prefix):
	var options = []
	for child in get_children():
		if prefix in child.name:
			 options.append(child)
	var index = randi() % len(options)
	options[index].play()

