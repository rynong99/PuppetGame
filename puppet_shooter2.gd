extends CharacterBody3D

@onready var projectile = preload("res://test1/projectile.tscn")


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var health := 5

@onready var body = $Body
@onready var head = $Body/Neck/Head
@onready var face_cam = $Body/Neck/Head/SubViewportContainer/SubViewport/FaceCam
@onready var face_cam_marker = $Body/Neck/Head/FaceCamMarker
@onready var head_top = $Body/Neck/Head/HeadTop



@export var copy_amount := 0.5
@export var tilt_threshold := 0.5



func _physics_process(delta):
	if not is_on_floor():
		print("falling")
		velocity += get_gravity() * delta

	if is_on_floor() and detect_spin(delta) != 0:
		print("spinning")
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_vector("arm_right","arm_left","arm_forward","arm_back")

	var tilt = Input.get_axis("arm_right","arm_left")
	if tilt < -tilt_threshold:
		velocity.x += delta	* 20
	elif tilt > tilt_threshold:
		velocity.x -= delta	* 20
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * 30)

	face_cam.global_transform = face_cam_marker.global_transform

	body.rotation.z = Input.get_axis("arm_right", "arm_left") * copy_amount
	body.rotation.x = Input.get_axis("arm_forward", "arm_back") * copy_amount

	head_top.rotation.x = lerp(head_top.rotation.x, remap(Input.get_action_strength("mouth"), 0, 1, 0, 1.3), delta * 15)

	print(direction.y)

	if direction.y < -0.3:
		head_top.rotation.x = lerp(head_top.rotation.x, 1.3, delta * 15)
		fire_projectile()
	
	move_and_slide()

func fire_projectile():
	#Instantiate a rigidbody projectile at the puppet head, add force to fire
	var proj = projectile.instantiate()
	proj.global_transform = head.global_transform
	proj.apply_central_impulse(- head.global_transform.basis.rotated(Vector3.LEFT, -PI/4).z* 10)
	get_parent().add_child(proj)

var is_clockwise = false
var last_diagonal = Vector2.ZERO
var crossings = 0
var spin_threshold = 3
var spin_timeout = 0.5
var time_since_crossing = 0.0

func detect_spin(delta) -> int:
	time_since_crossing += delta
	var joystick = Input.get_vector("arm_right","arm_left","arm_forward","arm_back")
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
