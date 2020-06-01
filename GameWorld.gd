extends Node2D


#Note for Erros: most of the code here, at least the base dungeon generation code came from this tutorial
#Tut: https://www.youtube.com/watch?v=o3fwlk1NI-w&list=PLarFYQwcbKf64eCY4vf_lKH1w5rbNUHKs&index=3
#Source code: https://github.com/kidscancode/godot3_procgen_demos/tree/master/part08/Godot3_DungeonGen03


var Room = preload("res://RoomTemplate.tscn")
var font = preload("res://Font.tres")
var Player = preload("res://Player.tscn")
var EnemyTest = preload("res://EnemyBase.tscn")
var SmolSpider = preload("res://SmolSpider.tscn")
var SmolDemon = preload("res://SmolDemon2.tscn")
var BigDemon = preload("res://BigDemon.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rooms = 25
var min_size = 4
var max_size = 16
var hspread = 400
var cull = 0.5
var tile_size = 32

var min_enemies_per_room = 2
var max_enemies_per_room = 8
var max_total_enemies = 50

var path
var start_room = null
var end_room = null
var playing = false
var player = null

onready var Map = $TileMap

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
var floor_wall_above_left = 26
var floor_wall_above_right = 28
var inner_wall_inner_corner_ul = 12
var inner_wall_inner_corner_ur = 15
var floor_hall_up = 24
var floor_hall_down = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	make_rooms() # Replace with function body.
	yield(get_tree().create_timer(5), "timeout")
	make_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func make_rooms():
	for i in range(rooms):
		var pos = Vector2(rand_range(-hspread, hspread),0)
		var r = Room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
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
	if start_room:
		draw_string(font, start_room.position - Vector2(125, 0), "start", Color(1,1,1))
	if end_room:
		draw_string(font, end_room.position  - Vector2(125, 0), "end", Color(1,1,1))
	if playing:
		return
				
func _input(event):
	if event.is_action_pressed('ui_select'):
		if playing:
			player.queue_free()
			playing = false
		for n in $Rooms.get_children():
			n.queue_free()
		for e in $Enemies.get_children():
			e.queue_free()
		path = null
		start_room = null
		end_room = null
		make_rooms()
	if event.is_action_pressed("ui_focus_next"):
		make_map()
	if event.is_action_pressed("ui_accept"):
		player = Player.instance()
		add_child(player)
		player.position = start_room.position
		playing = true

func _process(delta):
	update()
	if end_room && player:
		if player.position.x >= end_room.position.x && (player.position.y >= end_room.position.y):
			get_tree().change_scene("res://TitleScreen.tscn")
	
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
	find_start_room()
	find_end_room()
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position-room.size, room.get_node("Shape").shape.extents * 2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(x,y,void_space)
	generate_rooms()
			
func generate_rooms():
	var corrs = []
	var e_count = 0
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size, room.get_node("Shape").shape.extents * 2)
		var s = (room.size / tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var upper_left = (room.position / tile_size).floor() - s
		
		#carve out the room
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(upper_left.x + x, upper_left.y + y, floor_default)
		
		#build and carve paths
		var p = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in corrs:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				carve_path(start,end)
			corrs.append(p)
			
		#finally, add bounding walls
		#corners
		if Map.get_cellv(Vector2(upper_left.x, upper_left.y)) != floor_default:
			Map.set_cell(upper_left.x, upper_left.y, top_left_corner)
		if Map.get_cellv(Vector2(upper_left.x + (s.x * 2 - 1), upper_left.y)) != floor_default:
			Map.set_cell(upper_left.x + (s.x * 2 - 1), upper_left.y, top_right_corner)
		if Map.get_cellv(Vector2(upper_left.x, upper_left.y + (s.y * 2 - 1))) != floor_default:
			Map.set_cell(upper_left.x, upper_left.y + (s.y * 2 - 1), bottom_left_corner)
		if Map.get_cellv(Vector2(upper_left.x + (s.x * 2 - 1), upper_left.y + (s.y * 2 - 1))) != floor_default:
			Map.set_cell(upper_left.x + (s.x * 2 - 1), upper_left.y + (s.y * 2 - 1), bottom_right_corner)
		
		#upper row stuff
		for x in range(1, s.x * 2 - 1):
			if Map.get_cellv(Vector2(upper_left.x + x, upper_left.y)) != floor_default:
				Map.set_cell(upper_left.x + x, upper_left.y, outer_wall_tr)
			if Map.get_cellv(Vector2(upper_left.x + x, upper_left.y + (s.y * 2 - 1))) != floor_default:
				Map.set_cell(upper_left.x + x, upper_left.y + (s.y * 2 - 1), outer_wall_bottom)
			if Map.get_cellv(Vector2(upper_left.x + x, upper_left.y + 1)) != floor_default:
				Map.set_cell(upper_left.x + x, upper_left.y + 1, inner_wall)
			#don't care whether this spot is a path or not since it's a floor tile as well
			Map.set_cell(upper_left.x + x, upper_left.y + 2, floor_wall_above)
			
		#outer walls and any missing floor tiles
		for y in range(1, s.y * 2 - 1):
			if Map.get_cellv(Vector2(upper_left.x, upper_left.y + y)) != floor_default:
				Map.set_cell(upper_left.x, upper_left.y + y, outer_wall_lc)
			if Map.get_cellv(Vector2(upper_left.x + (s.x * 2 - 1), upper_left.y + y)) != floor_default:
				Map.set_cell(upper_left.x + (s.x * 2 - 1), upper_left.y + y, outer_wall_rc)
			
		for y in range(3, s.y * 2 - 1):
			if Map.get_cellv(Vector2(upper_left.x + 1, upper_left.y + y)) != floor_default:
				Map.set_cell(upper_left.x + 1, upper_left.y + y, floor_default)
		
		#Random enemy spawns based on this tutorial: https://www.youtube.com/watch?v=xTMM8HLFy-A
		if room != start_room && room != end_room:
			var enemies_spawned = 0
			var enemies = min_enemies_per_room + randi() % (max_enemies_per_room - min_enemies_per_room)
			if e_count + enemies < max_total_enemies:
				for n in range(0, enemies):
					randomize()
					var enemy
					if randi() % 4 == 0:
						enemy = SmolSpider.instance()
					elif randi() % 50 == 0:
						enemy = SmolDemon.instance()
					elif randi() % 75 == 0:
						enemy = BigDemon.instance()
					else:
						enemy = EnemyTest.instance()
					$Enemies.add_child(enemy)
					randomize()
					var x = 1 + randi() % int(s.x * 2 - 2)
					randomize()
					var y = 2 + randi() % int(s.y * 2 - 3)
					#translate map coords to world coords
					var e_pos = Map.map_to_world(Vector2(upper_left.x + x, upper_left.y + y))
					enemy.position = e_pos
				e_count += enemies
			
			
		
			
func carve_path(pos1, pos2):
	print_debug(pos1)
	print_debug(pos2)
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
		
func find_start_room():
	var min_x = INF
	for room in $Rooms.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x

func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x
	
	
