extends Node2D

var room = preload("res://Dungeon.tscn")
var room_alt = preload("res://RoomTemplate.tscn")
onready var Map = $DungeonTiles
var tile_size = 32

# mapping tiles to indices...
var void_space = 9
var floor_default = 6
var inner_wall = 0
var outer_wall_lc = 5
var outer_wall_rc = 4
var outer_wall_tr = 1
var top_left_corner = 2
var bottom_left_corner = 10
var bottom_right_corner = 11
var top_right_corner = 3
var outer_wall_bottom = 8
var floor_wall_above = 19
var inner_wall_inner_corner_ul = 12
var inner_wall_inner_corner_ur = 15
var floor_hall_up = 24
var floor_hall_down = 30



var rooms = 50
var min_size = 4
var max_size = 16
var hspread = 400
var cull = 0.5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var path #AStar pathfinder
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	make_rooms()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func make_rooms():
	for i in range(rooms):
		var pos = Vector2(rand_range(-hspread, hspread),0)
		var r = room_alt.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
	# wait
	yield(get_tree().create_timer(1.1), "timeout")
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room_positions.append(Vector3(room.position.x, room.position.y, 0))
	yield(get_tree(), "idle_frame")
	# generate MST
	path = find_mst(room_positions)
		
func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(32, 223, 0), false)
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color(1,1,0), 15, true)
		
func _process(delta):
	update()

func _input(event):
	if event.is_action_pressed('ui_select'):
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		make_rooms()
	if event.is_action_pressed("ui_focus_next"):
		make_map()
		
func find_mst(nodes):
	var path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	while nodes:
		var min_dist = INF
		var min_pos = null
		var pos = null
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			for p2 in nodes:
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_pos = p2
					pos = p1
		var n = path.get_available_point_id()
		path.add_point(n, min_pos)
		path.connect_points(path.get_closest_point(pos), n)
		nodes.erase(min_pos)
	return path
	
	
	
func make_map():
	Map.clear()
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position-room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(x,y,void_space)
	generate_rooms()
	

func generate_rooms():
	var corrs = []
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var upper_left = (room.position / tile_size).floor() - s
		#Map.set_cell(s.x, s.y, top_right_corner)
		# generate outer top wall
		
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(upper_left.x + x, upper_left.y + y, floor_default)
		var p = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in corrs:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				carve_path(start,end)
			corrs.append(p)
	
	
func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(x, x_y.y, floor_default)
		Map.set_cell(x, x_y.y + y_diff, floor_default)
	for y in range(pos1.y, pos2.y, y_diff):
		Map.set_cell(y_x.x, y, floor_default)
		Map.set_cell(y_x.x + x_diff, y, floor_default)
