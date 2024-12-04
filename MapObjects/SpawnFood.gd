extends Node3D

#Replace coin.tscn with the scenes of the collectables
@onready var foods = [preload("res://MapObjects/Box.tscn"), preload("res://MapObjects/Pill.tscn"), preload("res://MapObjects/Ball.tscn")]
@onready var spawn_points = get_children()

@export var spawn_rate := 5.0
var time_since_spawn := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var drop = foods[randi() % foods.size()].instantiate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		time_since_spawn += delta
		if time_since_spawn >= spawn_rate:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			var drop = foods[randi() % foods.size()].instantiate()
			drop.position = spawn_point.position
			add_child(drop)
			time_since_spawn = 0.0
