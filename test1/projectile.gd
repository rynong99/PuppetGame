extends RigidBody3D

var time_since_spawn = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_since_spawn += delta
	if time_since_spawn > 5.0:
		queue_free()
	pass
