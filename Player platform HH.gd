extends KinematicBody2D
class_name PlayerPlatform

enum { MOVE, CLIMB }

export(Resource) var moveData = preload("res://Player Data/DefaultPlayerMovementData.tres") as PlayerMovementData

var velocity = Vector2.ZERO
var state = MOVE
var double_jump = 1
var jump_buffer = false
var coyote_jump = false

onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer = $CoyotejumpTimer

# You idiot. You forgot the func. You baby. I wuv u. you baby
func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)
		
func move_state(input):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB
	
	apply_gravity()
	
	if not horizontal_move(input):
		apply_friction()
		if is_on_floor():
			animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.flip_h = input.x < 0
		if is_on_floor():
			animatedSprite.animation = "Run"
		
	if is_on_floor():
		reset_double_jump()
	else:
		if(velocity.y > 0):
			animatedSprite.animation = "Fall"
		
	if can_jump():
		if Input.is_action_just_pressed("jump") or jump_buffer: #jump
			animatedSprite.animation = "Jump"
			velocity.y = moveData.JUMP_FORCE
			jump_buffer = false
	else:
		input_jump_release()
		input_double_jump()
		buffer_jump()
		fast_fall()
			
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()
	
func climb_state(input):
	if not is_on_ladder(): state = MOVE
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)
	
func input_jump_release():
	if Input.is_action_just_released("jump") and velocity.y < moveData.JUMP_RELEASE_FORCE:
		velocity.y = moveData.JUMP_RELEASE_FORCE
	
func input_double_jump():
	if Input.is_action_just_pressed("jump") and double_jump > 0:
		velocity.y = moveData.JUMP_FORCE
		double_jump -= 1
	
func buffer_jump():
	if Input.is_action_just_pressed("jump"):
		jump_buffer = true
		jumpBufferTimer.start()

func fast_fall():
	if velocity.y > 0:
		velocity.y += moveData.ADDITIONAL_FALL_GRAVITY

func can_jump():
	return is_on_floor() or coyote_jump
	
func horizontal_move(input):
	return input.x != 0
	
func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMPS_COUNT
	
func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true
		
func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION) 
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)
			
func _on_JumpBufferTimer_timeout():
	jump_buffer = false

func _on_CoyotejumpTimer_timeout():
	coyote_jump = false
