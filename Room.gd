extends RigidBody2D

var size
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func make_room(_pos, _size):
	position = _pos
	size = _size
	var rect = RectangleShape2D.new()
	rect.custom_solver_bias = 0.75
	rect.extents = size
	$CollisionShape2D.shape = rect

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
