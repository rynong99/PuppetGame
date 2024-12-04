extends Node3D
# Called when the node enters the scene tree for the first time.
var lifespan := 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifespan += 1
	if (lifespan > 1000):
		self.queue_free()
		lifespan = 0
