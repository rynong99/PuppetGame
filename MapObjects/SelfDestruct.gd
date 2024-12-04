extends Node3D
# Called when the node enters the scene tree for the first time.
var lifespan := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifespan += delta
	if (lifespan >= 20.0):
		var tween = create_tween()
		tween.tween_property($CollisionShape3D, "scale", Vector3.ZERO, 0.5)
		await tween.finished
		queue_free()
