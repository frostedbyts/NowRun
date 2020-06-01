extends KinematicBody2D

var max_speed = 220
var speed = 0
var accel = 1200
var m_dir = Vector2(0,0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var hp_bar = get_node("HP").get_node("HealthBar")
var max_hp = 300
var curr_hp

var can_fire = true
var rof = 0.2

var bullet = preload("res://Bullet.tscn")

func _input(event):
	if event.is_action_pressed("ScrollUp"):
		$Camera2D.zoom = $Camera2D.zoom - Vector2(0.2,0.2)
	if event.is_action_pressed("ScrollDown"):
		$Camera2D.zoom = $Camera2D.zoom + Vector2(0.2, 0.2)

# Called when the node enters the scene tree for the first time.
func _ready():
	curr_hp = max_hp # Replace with function body.

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
func dead():
	get_node("CollisionPolygon2D").set_deferred("disabled", true)
	get_tree().change_scene("res://TitleScreen.tscn")
	self.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	AnimLoop()
	AttackLoop()

func _physics_process(delta):
	MoveLoop(delta)
	

func MoveLoop(delta):
	m_dir.x = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	m_dir.y = (int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))) / float(2)
	if m_dir == Vector2(0,0):
		speed = 0
	else:
		speed += accel * delta
		if speed > max_speed:
			speed = max_speed
		var motion = m_dir.normalized() * speed
		move_and_slide(motion)
	
func AnimLoop():
	var anim_dir = "down"
	var anim_mode = "idle"
	var animation
	match m_dir:
		Vector2(1,0):
			anim_dir = "right"
		Vector2(-1,0):
			anim_dir = "left"
		Vector2(0,0.5):
			anim_dir = "down"
		Vector2(0,-0.5):
			anim_dir = "up"
		Vector2(1,-0.5):
			anim_dir = "right"
		Vector2(1,0.5):
			anim_dir = "right"
		Vector2(-1,-0.5):
			anim_dir = "left"
		Vector2(-1,0.5):
			anim_dir = "left"
	if m_dir != Vector2(0,0):
		anim_mode = "run"
	else:
		anim_mode = "idle"
	animation = anim_mode + "_" + anim_dir
	get_node("AnimationPlayer").play(animation)

#Based on these tutorials 
#https://www.youtube.com/watch?v=isA7P9ulBwE&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly&index=1
#https://www.youtube.com/watch?v=hf_Ce8FdMGM&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly&index=2
func AttackLoop():
	if Input.is_action_pressed("Shoot") && can_fire:
		can_fire = false;
		get_node("Axis").rotation = get_angle_to(get_global_mouse_position())
		var bullet_inst = bullet.instance()
		bullet_inst.position = get_node("Axis/SpawnPoint").get_global_position()
		bullet_inst.rotation = get_angle_to(get_global_mouse_position())
		get_parent().add_child(bullet_inst)
		yield(get_tree().create_timer(rof), "timeout")
		can_fire = true

