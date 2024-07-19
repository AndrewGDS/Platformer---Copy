extends KinematicBody2D

const SPEED = 300
const JUMP_VELOCITY = 400
const UP = Vector2(0, -1)
const MAXFALLSPEED = 1200
const MAXSPEED = 80

const JUMPFORCE = 300

var velocity = Vector2()

#Settings
var gravity = 20

func _physics_process(delta):
	
	#gravity
	if not is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -JUMPFORCE
		
	if Input.is_action_just_pressed("right") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction = Input.get_axis("left", "left")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide(velocity,UP)
