extends KinematicBody2D

#Based on these tutorials 
#https://www.youtube.com/watch?v=isA7P9ulBwE&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly&index=1
#https://www.youtube.com/watch?v=hf_Ce8FdMGM&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly&index=2
#https://kidscancode.org/godot_recipes/ai/chase/

onready var hp_bar = get_node("HP").get_node("HealthBar")

var player_in_range = false
var player_in_sight = true

var velocity = Vector2.ZERO
var player = null

var can_attack = false

export  (int) var max_hp
export (int) var damage
export (int) var speed
var curr_hp
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _process(delta):
	pass
	
func _physics_process(delta):
	velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.position) * speed
	velocity = move_and_slide(velocity)

# Called when the node enters the scene tree for the first time.
func _ready():
	curr_hp = max_hp
	
func on_hit(damage):
	curr_hp -= damage
	hp_bar_update()
	if curr_hp <= 0:
		dead()

#https://www.youtube.com/watch?v=h5slNt__Tt8&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly&index=3
func hp_bar_update():
	var percent = int((float(curr_hp) / max_hp) * 100)
	get_node("HP/HealthBar/Tween").interpolate_property(hp_bar, "value", hp_bar.value, percent, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	get_node("HP/HealthBar/Tween").start()
	if percent >= 60:
		hp_bar.set_tint_progress("14e114")#Green
	elif percent <= 75 && percent >= 50:
		hp_bar.set_tint_progress("e1be32")#Orange
	else:
		hp_bar.set_tint_progress("e11e1e")#Red


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func dead():
	get_node("CollisionPolygon2D").set_deferred("disabled", true)
	get_node("Sight/CollisionShape2D").set_deferred("disabled", true)
	get_node("Hitbox/CollisionPolygon2D").set_deferred("disabled", true)
	self.hide()
	
func Attack():
	pass

#https://www.youtube.com/watch?v=aM8bRYH3_Po&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly&index=9
#https://kidscancode.org/godot_recipes/ai/chase/
func _on_Sight_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true;
		player = body


func _on_Sight_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		player = null
		


func _on_Hitbox_body_entered(body):
	if body.is_in_group("Player"):
		can_attack = true
		body.on_hit(damage)


func _on_Hitbox_body_exited(body):
	if body.is_in_group("Player"):
		can_attack = false
