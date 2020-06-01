extends RigidBody2D

var projectile_vel = 400
var lifetime = 3
var dmg = 5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	apply_impulse(Vector2(), Vector2(projectile_vel, 0).rotated(rotation)) # Replace with function body.

func destroy():
	yield(get_tree().create_timer(lifetime), "timeout")
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#Based on these tutorials 
#https://www.youtube.com/watch?v=isA7P9ulBwE&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly&index=1
#https://www.youtube.com/watch?v=hf_Ce8FdMGM&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly&index=2
func _on_Bullet_body_entered(body):
	get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if body.is_in_group("Enemies"):
		print("enemy")
		body.on_hit(dmg)
	self.hide() # Replace with function body.
