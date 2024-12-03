extends Node3D

const MAX_BLOBS = 50

@export var mat : Material

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var bodies = get_children()
	
	
	var blobs = PackedFloat32Array()
	var blobs_color : Array[float] = []
	for body in bodies:
		if body is not PinJoint3D:
			var p = body.global_position
			blobs.append(p.x)
			blobs.append(p.y)
			blobs.append(p.z)
			blobs.append(body.collision_shape.scale.x * 0.1)
			if body.p1_shot:
				blobs_color.append(0.0)
			else:
				blobs_color.append(1.0)
			#blobs_color.append(body.p1_shot)
	
	var num_blobs = (int)(blobs.size() / 4)
	if num_blobs > MAX_BLOBS:
		var remove
		for body in bodies:
			if body is not PinJoint3D:
				if remove == null:
					remove = body
				elif remove.time_since_spawn > body.time_since_spawn:
					if body.mass - 2.0 > remove.mass:
						pass
					else:
						remove = body
		if remove != null:
			remove.queue_free()

				
	mat.set_shader_parameter("blobs", blobs)
	mat.set_shader_parameter("blob_count", clamp(num_blobs, 0, MAX_BLOBS))
	mat.set_shader_parameter("blob_color", blobs_color)