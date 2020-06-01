extends TileMap

var grid = []
var min_size = 4
var max_size = 16

#tile indices
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
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var grid_width = min_size + randi() % (max_size - min_size)
	var grid_height = min_size + randi() % (max_size - min_size)
	var width = grid_width + 2
	var height = grid_height + 3
	grid.resize(width)
	for n in width:
		grid[n] = []
		grid[n].resize(height)
		for m in height:
			grid[n][m] = randi() % 2
	
	set_cell(0,0,top_left_corner)
	set_cell(width- 1, 0, top_right_corner)
	set_cell(0,height - 1, bottom_left_corner)
	set_cell(width - 1, height - 1, bottom_right_corner)
	set_cell(0,2,floor_wall_above_left)
	set_cell(width - 1, 1, floor_wall_above_right)
	
	
	for x in range(1, width - 1):
		set_cell(x, 0, outer_wall_tr)
		set_cell(x, height - 1, outer_wall_bottom)
		set_cell(x,1,inner_wall)
		set_cell(x,2,floor_wall_above)
		
	for y in range(1, height - 1):
		set_cell(0,y, outer_wall_lc)
		set_cell(width - 1, y, outer_wall_rc)
	
	for x in range(1, width -1):
		for y in range(3, height - 1):
			set_cell(x,y,floor_default)
	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
