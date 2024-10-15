extends Node3D

@onready var head = $Head
@onready var head_top = $Head/HeadTop
@onready var projectile = preload("res://test1/projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	rotation.z = Input.get_axis("arm_right", "arm_left")
	rotation.x = Input.get_axis("arm_forward", "arm_back")

	head.rotation.x = Input.get_axis("hand_down", "hand_up")
	head.rotation.y = Input.get_axis("hand_left", "hand_right")

	head_top.rotation.x = remap(Input.get_action_strength("mouth"), 0, 1, 0, 1.3)

	if Input.is_action_just_pressed("mouth"):
		fire_projectile()
	
func fire_projectile():
	#Instantiate a rigidbody projectile at the puppet head, add force to fire
	var proj = projectile.instantiate()
	proj.global_transform = head.global_transform
	proj.apply_central_impulse(- head.global_transform.basis.z * 10)
	get_parent().add_child(proj)
