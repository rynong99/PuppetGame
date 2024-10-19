extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation.z += delta
	pass


func _on_body_entered(body:Node3D):
	if body.has_method("hurt"):
		body.hurt(1)
	pass # Replace with function body.
