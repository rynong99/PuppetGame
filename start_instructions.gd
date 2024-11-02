extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	get_tree().paused = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var p1_joy = Input.get_vector("arm_right", "arm_left", "arm_forward", "arm_back")
	var p2_joy = Input.get_vector("hand_right", "hand_left", "hand_up", "hand_down")

	if detect_spin(delta, p1_joy) != 0 and detect_spin(delta, p2_joy) != 0:
		visible = false
		get_tree().paused = false
	pass

var is_clockwise = false
var last_diagonal = Vector2.ZERO
var crossings = 0

## Number of crossings before spinning starts
@export var spin_threshold = 3

## Time since last spin crossing to stop spinning
@export var spin_timeout = 0.5
var time_since_crossing = 0.0

func detect_spin(delta, joystick : Vector2) -> int:
	time_since_crossing += delta
	if joystick == Vector2.ZERO:
		crossings = 0
		return 0

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
