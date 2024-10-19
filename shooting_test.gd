extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func fire_projectile():
	#Instantiate a rigidbody projectile at the puppet head, add force to fire
	var proj = projectile.instantiate()
	proj.global_transform = head.global_transform
	proj.apply_central_impulse(- head.global_transform.basis.z * 10)
	get_parent().add_child(proj)
