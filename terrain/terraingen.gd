extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	genterrain(750, 100);

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func genterrain(width: float, height: float):
	print("Generate terrain!");
	
	var verts = PoolVector2Array()
	
	var sc: float = 100;
	var wave_h: float = 50;
	var division_count = 100;
	
	var ground_points = [];
	
	for i in range(0, division_count):
		var i_f = float(i);
		var t: float = i_f / division_count;
		var x = t * width;
		
		ground_points.push_back(Vector2(
			t * width,
			sin(t * PI * 6) * wave_h
		));
		
	for i in range(1, ground_points.size() - 1):
		# a---b
		# | \ |
		# d---c
		var p_a = ground_points[i - 1];
		var p_b = ground_points[i];
		var p_c = Vector2(p_b.x, height);
		var p_d = Vector2(p_a.x, height);
		
		verts.push_back(p_a);
		verts.push_back(p_b);
		verts.push_back(p_c);
		
		verts.push_back(p_a);
		verts.push_back(p_c);
		verts.push_back(p_d);
	
	# Initialize the ArrayMesh.
	var arrs = []
	arrs.resize(ArrayMesh.ARRAY_MAX)
	arrs[ArrayMesh.ARRAY_VERTEX] = verts
	
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrs)
	
	get_node("terrain_mesh").mesh = arr_mesh
	
	var col = PoolVector2Array();
	col.append_array(ground_points);
	col.append(Vector2(ground_points.back().x, height));
	col.append(Vector2(ground_points.front().x, height));
	get_node("StaticBody2D/CollisionPolygon2D").polygon = col;
