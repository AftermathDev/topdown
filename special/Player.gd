extends KinematicBody2D

const MOVESPEED = 500

onready var root = get_tree().get_root()

var health = 100

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	
	var motion = Vector2()
	
	# check if button pressed
	if Input.is_action_pressed("player_up"):
		motion.y -= 1
	if Input.is_action_pressed("player_down"):
		motion.y += 1
	if Input.is_action_pressed("player_left"):
		motion.x -= 1
	if Input.is_action_pressed("player_right"):
		motion.x += 1
	
	# now apply that to the player
	motion = motion.normalized()                 # make it so you don't go faster when diagnal
	motion = move_and_slide(motion * MOVESPEED) # make the player collidable
	look_at(get_global_mouse_position())        # as with most top-down shooters, you should be able to aim
	
