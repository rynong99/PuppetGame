extends Node3D

@onready var projectile = preload("res://projectile_2.tscn")
@onready var healthbar = $"../UI/HealthBar"
var health = 10
@export var spawn_area_width := 10.0
@export var spawn_area_height := 10.0
var time_since_shoot := 0.0
@export var fire_rate := 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	time_since_shoot += delta
	if time_since_shoot >= fire_rate:
		var hit = projectile.instantiate()
		hit.global_position= Vector3(randf_range(-spawn_area_width/2, spawn_area_width/2), randf_range(-spawn_area_height/2, spawn_area_height/2), 0.0)
		add_child(hit)
		time_since_shoot = 0.0


func _on_area_3d_body_entered(body:Node3D):
	body.queue_free()
	health -= 1
	healthbar.value = health
	pass # Replace with function body.
