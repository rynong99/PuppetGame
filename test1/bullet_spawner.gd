extends Node3D

@onready var projectile = preload("res://test1/projectile.tscn")
var time_last_projectile := 0.0
@onready var puppet_head := $"../Puppet/Head"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(puppet_head.global_position + Vector3(0,1,0))
	time_last_projectile += delta
	if time_last_projectile > 1.0:
		fire_projectile()
		time_last_projectile = 0.0
	pass

func fire_projectile():
	#Instantiate a rigidbody projectile at the puppet head, add force to fire
	var bullet = projectile.instantiate()
	bullet.global_transform = global_transform
	bullet.apply_central_impulse(- global_transform.basis.z * 20)
	get_parent().add_child(bullet)
