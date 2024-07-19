extends KinematicBody2D
class_name Player

export(Resource) var moveData
# x = 0, y = 0
var motion = Vector2()

onready var ladderCheck = $LadderCheck

func _physics_process(delta):
	if is_on_ladder():
		print("on ladder")
	
	#gravity
	motion.y += moveData.GRAVITY
	var friction = false
	
	if Input.is_action_pressed("right"):
		motion.x = min(motion.x+moveData.ACCELERATION, moveData.MAX_SPEED)
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("Run")
	elif Input.is_action_pressed("left"):
		motion.x = max(motion.x-moveData.ACCELERATION, -moveData.MAX_SPEED)
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("Run")
	else:
		$AnimatedSprite.play("Idle")
		friction = true
		
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			motion.y = moveData.JUMP_HEIGHT
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
	else:
		if motion.y < 0:
			$AnimatedSprite.play("Jump")
		else:
			$AnimatedSprite.play("Fall")
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

	motion = move_and_slide(motion, moveData.UP)
	pass
