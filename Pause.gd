extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("Pause"):
		var state = not get_tree().paused
		get_tree().paused = state
		visible = state


func _on_MenuButton_pressed():
	get_tree().change_scene("res://GameWorld.tscn") # Replace with function body.


func _on_MenuButton2_pressed():
	get_tree().quit() # Replace with function body.
