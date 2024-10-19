extends CharacterBody3D

var score := 0
var health := 10
@export var speed := 5.0
@export var fly_velocity = 4.5

## How far the joystick has to be tilted to start rotating the player
@export var tilt_threshold := 0.5

## How much the head copies the joystick movement
@export var copy_amount := 0.5

## Speed when not wiggling (5.0 is the full wiggling speed)
@export var not_wiggle_speed := 0.0

## How much the head has to be tilted to start vomit
@export var vomit_threshold := 0.7

## Time puppet has to be held forward to start vomit
@export var vomit_hold_time := 0.3

var vomit_time = 0.0

@onready var body = $Body
@onready var head_top = $Body/Neck/Head/HeadTop
@onready var head = $Body/Neck/Head
@onready var face_cam = $Body/Neck/Head/SubViewportContainer/SubViewport/FaceCam
@onready var face_cam_marker = $Body/Neck/Head/FaceCamMarker
@onready var audio_player = $Body/Neck/Head/AudioStreamPlayer3D

#Temp projectile
@onready var projectile = preload("res://test1/projectile.tscn")

var face_cam_pos_offset = Vector3(0,0,-2)
var face_cam_rot_offset = Vector3(0,-180,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func hurt(amount):
	health -= amount

func fire_projectile():
	#Instantiate a rigidbody projectile at the puppet head, add force to fire
	var proj = projectile.instantiate()
	proj.global_transform = head.global_transform
	#rotate target direction upwards
	var target_direction = Vector3(0,0.5,-1).normalized().rotated(Vector3.UP, rotation.y) * 10
	proj.apply_central_impulse(target_direction)
	get_parent().add_child(proj)

func _physics_process(delta):
	$ScoreLabel.text = "Score: " + str(score) + "\n Health :" + "♥".repeat(health)
	face_cam.global_transform = face_cam_marker.global_transform
	
	if detect_spin(delta) != 0:
		wiggle_counter = 0
		if !audio_player.playing:
			audio_player.stream = load("res://audio/woo.mp3")
			audio_player.play()
		$SpinParticles.emitting = true
		velocity.y = lerp(velocity.y, fly_velocity, delta * 50)
		#velocity.x = lerp(velocity.x, 0.0, delta * 30)
		#velocity.z = lerp(velocity.z, 0.0, delta * 30)
	else:
		$SpinParticles.emitting = false
		var tilt = Input.get_axis("arm_right","arm_left")
		if tilt < -tilt_threshold:
			rotation.y -= delta	* 5
		elif tilt > tilt_threshold:
			rotation.y += delta	* 5
		
	if detect_wiggling(delta):
		if !audio_player.playing:
			audio_player.stream = load("res://audio/hup.wav")
			audio_player.play()
		var target_velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) *speed
		velocity.x = lerp(velocity.x, target_velocity.x, delta * 50)
		velocity.z = lerp(velocity.z, target_velocity.z, delta * 50)
	else:
		velocity.x = lerp(velocity.x, Vector3.FORWARD.rotated(Vector3.UP, rotation.y).x * not_wiggle_speed, delta * 30)
		velocity.z = lerp(velocity.z, Vector3.FORWARD.rotated(Vector3.UP, rotation.y).z * not_wiggle_speed, delta * 30)
			
	if not is_on_floor():
			velocity.y += get_gravity().y * delta
	
	body.rotation.z = Input.get_axis("arm_right", "arm_left") * copy_amount
	body.rotation.x = Input.get_axis("arm_forward", "arm_back") * copy_amount

	var lean_forward = Input.get_axis("arm_forward", "arm_back")

	if lean_forward < -vomit_threshold:
		if vomit_time > vomit_hold_time:
			fire_projectile()
		vomit_time += delta
	else: 
		vomit_time = 0.0
	head_top.rotation.x = clamp(-lean_forward, 0, 1.3)
	move_and_slide()


var previous_wiggle_position = 0
var wiggle_counter = 0

## Number of times the joystick has to be tilted to start wiggle moment
@export var wiggle_threshold := 2

## Time since last tilt to stop wiggle
@export var wiggle_timeout := 0.5

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

## Number of crossings before spinning starts
@export var spin_threshold = 3

## Time since last spin crossing to stop spinning
@export var spin_timeout = 0.5
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
				#is_clockwise = true

	last_diagonal = Vector2(sign(joystick.x),sign(joystick.y))

	if time_since_crossing > spin_timeout:
		crossings = 0
		
	if crossings > spin_threshold:
		if is_clockwise:
			return 1
		else:
			return -1
	return 0
