extends ColorRect

@export var tilt_threshold := 0.5

#Variables for wiggling detection


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):

	var tilt = Input.get_axis("arm_right","arm_left")
	if tilt < -tilt_threshold:
		rotation -= delta	* 5
	elif tilt > tilt_threshold:
		rotation += delta	* 5

	if detect_spin(delta):
		color = Color(0, 1, 0, 1)
	else: 
		if detect_wiggling(delta):
			color = Color(1, 0, 0, 1)
		else:
			color = Color(1, 1, 1, 1)


var previous_wiggle_position = 0
var wiggle_counter = 0
var wiggle_threshold = 4
var wiggle_timeout = 0.2
var time_since_last_wiggle = 0.0

func detect_wiggling(delta: float) -> bool:
	var current_wiggle_position = Input.get_axis("arm_back","arm_forward")
	if sign(current_wiggle_position) != sign(previous_wiggle_position):
		wiggle_counter += 1
		time_since_last_wiggle = 0
	else:
		time_since_last_wiggle += delta
	
	if time_since_last_wiggle > wiggle_timeout:
		wiggle_counter = 0
	
	previous_wiggle_position = current_wiggle_position

	if wiggle_counter > wiggle_threshold:
		return true
	
	return false

var is_clockwise = false
var last_diagonal = Vector2.ZERO
var crossings = 0
var spin_threshold = 4
var spin_timeout = 0.5
var time_since_crossing = 0.0

func detect_spin(delta) -> int:
	var joystick = Input.get_vector("arm_right","arm_left","arm_forward","arm_back")
	time_since_crossing += delta

	if sign(last_diagonal.x) < sign(joystick.x):
		if sign(joystick.y) == 1:
			if is_clockwise:
				crossings += 1
				time_since_crossing = 0
			else:
				crossings = 0
				is_clockwise = true
		elif sign(joystick.y) == -1:
			if not is_clockwise:
				crossings += 1
				time_since_crossing = 0
			else:
				crossings = 0
				is_clockwise = false
	elif sign(last_diagonal.x) > sign(joystick.x):
		if sign(joystick.y) == 1:
			if not is_clockwise:
				crossings += 1
				time_since_crossing = 0
			else:
				crossings = 0
				is_clockwise = false
		elif sign(joystick.y) == -1:
			if is_clockwise:
				crossings += 1
				time_since_crossing = 0
			else:
				crossings = 0
				is_clockwise = true

	last_diagonal = Vector2(sign(joystick.x),sign(joystick.y))

	if time_since_crossing > spin_timeout:
		crossings = 0
		
	if crossings > spin_threshold:
		if is_clockwise:
			return 1
		else:
			return -1
	return 0