extends Node3D

@onready var food = preload("res://MapObjects/FoodDrop.tscn")
@onready var spawn_points = get_children()
@export var spawn_rate := 5.0
var time_since_spawn := 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var drop = food.instantiate()
	spawn_point.add_child(drop)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		time_since_spawn += 1
		if time_since_spawn >= 250:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			var drop = food.instantiate()
			spawn_point.add_child(drop)
			time_since_spawn = 0
