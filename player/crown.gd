extends Sprite



var player = null
var target_crown = null



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_position(delta):
	var y_speed = 1000
	
	if is_instance_valid(target_crown):
		var target_pos = target_crown.global_position + Vector2(0, -10) # get offset
		var self_pos = global_position
		var delta_y = target_pos.y - self_pos.y
		var delta_x = target_pos.x - self_pos.x
		delta_x = clamp(delta_x, -2, 2)
		var move_y = 0
		if delta_y > 0:
			move_y = y_speed * delta
			if move_y > delta_y:
				move_y = delta_y
		else:
			move_y = -y_speed * delta
			if move_y < delta_y:
				move_y = delta_y
		
		global_position = Vector2(target_pos.x - delta_x, self_pos.y + move_y)
		
