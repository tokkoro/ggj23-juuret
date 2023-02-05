extends Node2D

class_name Terraingen

export var ground_far_color: Color = Color.black;
export var ground_surface_color: Color = Color(0.58, 0.23, 0.02, 1.0);

var ground_width = 1350
var ground_offset = 150
var ground_height = 250

func get_terrain_whole_height():
	return (ground_height + ground_offset) * 2.0;

func generate_terrain():
	var terrain_old = get_node_or_null("terrain")
	if terrain_old:
		print("Remove old terrain")
		terrain_old.name = "terrain_old" # Has to be renamed to avoid having two "terrain" nodes at the same time
		terrain_old.queue_free()
	
	print("Generate new terrain root")
	
	var terrain_node = Node2D.new()
	terrain_node.name = "terrain"

	genterrain(
		terrain_node,
		ground_width,
		ground_height,
		ground_offset,
		rand_range(0, 1e16),
		true
	)
	
	genterrain(
		terrain_node,
		ground_width,
		-ground_height,
		-ground_offset,
		rand_range(0, 1e16),
		false
	)
	
	gen_side_body(terrain_node, ground_width, (ground_height + ground_offset) * 2.0, 1)
	gen_side_body(terrain_node, ground_width, (ground_height + ground_offset) * 2.0, -1)
	
	add_child(terrain_node)

func stop_colliding():
	for c in get_node('./terrain').get_children():
		for c_2 in c.get_children():
			if c_2 is CollisionPolygon2D:
				print("Stop colliding " + name + " child " + c_2.name)
				c_2.disabled = true
				
func start_colliding():
	for c in get_node('./terrain').get_children():
		for c_2 in c.get_children():
			if c_2 is CollisionPolygon2D:
				print("Start colliding " + name + " child " + c_2.name)
				c_2.disabled = false



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	## No need to listen to this signal. All terrains are left as is when next round starts
	#var maailma = find_parent("Maailma")
	#if maailma:
	#	print("Connecting terrain generation to transition_halfway signal")
	#	maailma.connect("transition_halfway", self, "generate_terrain")
	
	generate_terrain()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

class GroundPoint:
	var p: Vector2
	var color: Color

func gen_side_body(root: Node2D, width: float, height: float, dir: float):
	var rect_ext_w = 100;
	var rect = RectangleShape2D.new()
	rect.set_extents(Vector2(rect_ext_w, height / 2.0))
	
	var body = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	body.add_child(shape)
	shape.shape = rect
	shape.position = Vector2(width / 2.0 + rect_ext_w, 0) * dir

	root.add_child(body);

func genterrain(root: Node2D, width: float, height: float, offset: float, seed_v: float, add_collision:bool):
	print("Generate terrain!");
	
	var division_count = 129;
	var wave_h: float = 150;
	var wave_f_arr = [];
	var rand_h = 0;
	var rand_gen = RandomNumberGenerator.new()
	rand_gen.seed = seed_v;
	for wave_i in range(0, 64):
		wave_f_arr.push_back(rand_gen.randf() * rand_range(4, 30));
	
	var ground_points = [];
	for i in range(0, division_count + 1):
		var i_f = float(i);
		var t: float = i_f / division_count;
		var gp = GroundPoint.new();
		
		var h = 0;
		for wave_f in wave_f_arr:
			h += sin(wave_f * PI * t + float(i) / division_count) * wave_h / wave_f_arr.size()
			
		gp.p = Vector2(
			t * width - width / 2, # center around node origin
			h + offset
		);
		
		gp.color = ground_surface_color.linear_interpolate(Color.black, rand_range(0, 0.1));
		
		ground_points.push_back(gp);
	
	var verts = PoolVector2Array()
	var colors = PoolColorArray()
	for i in range(1, ground_points.size()):
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
	
	var mesh_node = MeshInstance2D.new()
	mesh_node.mesh = arr_mesh
	root.add_child(mesh_node)
	
	var col = PoolVector2Array();
	for gp in ground_points:
		col.append(gp.p);
	col.append(Vector2(ground_points.back().p.x, offset + height));
	col.append(Vector2(ground_points.front().p.x, offset + height));
	var body = StaticBody2D.new();
	body.set_collision_mask_bit(10, true)
	var body_shape = CollisionPolygon2D.new();
	body_shape.polygon = col;
	body.add_child(body_shape)
	body_shape.disabled = !add_collision
	root.add_child(body)
	
