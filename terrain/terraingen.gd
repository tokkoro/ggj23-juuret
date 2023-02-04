extends Node2D

var ground_far_color: Color = Color.brown.linear_interpolate(Color.black, 0.75);

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
	genterrain(1280, 500, 150, rand_range(0, 1e16));

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

class GroundPoint:
	var p: Vector2
	var color: Color


func genterrain(width: float, height: float, offset: float, seed_v: float):
	print("Generate terrain!");
	
	var sc: float = 100;
	var division_count = 128;
	
	var wave_h: float = 100;
	var wave_f_arr = [];
	var rand_h = 0;
	var rand_gen = RandomNumberGenerator.new()
	rand_gen.seed = seed_v;
	for wave_i in range(0, 64):
		wave_f_arr.push_back(rand_gen.randf() * rand_range(4, 30));
	
	var ground_points = [];
	for i in range(0, division_count):
		var i_f = float(i);
		var t: float = i_f / division_count;
		var gp = GroundPoint.new();
		
		var h = 0;
		for wave_f in wave_f_arr:
			h += sin(wave_f * PI * t) * wave_h / wave_f_arr.size()
			
		gp.p = Vector2(
			t * width - width / 2, # center around node origin
			h + offset
		);
		
		gp.color = Color.brown.linear_interpolate(Color.black, rand_range(0, 0.3));
		
		ground_points.push_back(gp);
	
	var verts = PoolVector2Array()
	var colors = PoolColorArray()
	for i in range(1, ground_points.size() - 1):
		var i_a = i - 1;
		var i_b = i;
		
		var gp_a = ground_points[i - 1];
		var gp_b = ground_points[i];
		
		# a---b
		# | \ |
		# d---c
		var p_a = gp_a.p;
		var p_b = gp_b.p;
		var p_c = Vector2(p_b.x, offset + height);
		var p_d = Vector2(p_a.x, offset + height);
		
		verts.push_back(p_a);
		colors.push_back(gp_a.color);
		verts.push_back(p_b);
		colors.push_back(gp_b.color);
		verts.push_back(p_c);
		colors.push_back(ground_far_color);
		
		verts.push_back(p_a);
		colors.push_back(gp_a.color);
		verts.push_back(p_c);
		colors.push_back(ground_far_color);
		verts.push_back(p_d);
		colors.push_back(ground_far_color);
		
	
	# Initialize the ArrayMesh.
	var arrs = []
	arrs.resize(ArrayMesh.ARRAY_MAX)
	arrs[ArrayMesh.ARRAY_VERTEX] = verts
	arrs[ArrayMesh.ARRAY_COLOR] = colors
	
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrs)
	
	get_node("terrain_mesh").mesh = arr_mesh
	
	var col = PoolVector2Array();
	for gp in ground_points:
		col.append(gp.p);
	col.append(Vector2(ground_points.back().p.x, offset + height));
	col.append(Vector2(ground_points.front().p.x, offset + height));
	get_node("terrain_body/poly").polygon = col;
	
