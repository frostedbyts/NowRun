extends RigidBody2D

var playable_width
var playable_height
var width
var height

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

var min_size = 4
var max_size = 16
var tile_size = 32

var grid = []
var size

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#https://www.youtube.com/watch?v=o3fwlk1NI-w
func make_room(_pos, _size):
	position = _pos
	size = _size
	var rect = RectangleShape2D.new()
	rect.custom_solver_bias = 0.75
	rect.extents = size
	$Shape.shape = rect
	
	width = _size.x
	height = _size.y
	
	playable_width = width - 2
	playable_height = height - 3
	grid.resize(width)
	for n in width:
		grid[n] = []
		grid[n].resize(height)
		for m in height:
			grid[n][m] = randi() % 2
