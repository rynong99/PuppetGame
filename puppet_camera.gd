extends SpringArm3D

@onready var puppet = get_parent()
@onready var camera = $Camera3D

var y_damping = 0.02  # Damping factor for y-axis
var damping = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if puppet:
		update_position(delta)
		update_rotation(delta)
		update_camera(delta)

func update_position(delta):
	var target_position = puppet.global_transform.origin + Vector3(0, 10, 0)
	global_transform.origin.x = lerp(global_transform.origin.x, target_position.x, damping)
	global_transform.origin.z = lerp(global_transform.origin.z, target_position.z, damping)
	global_transform.origin.y = lerp(global_transform.origin.y, target_position.y, y_damping)

func update_rotation(delta):
	global_rotation.y = lerp_angle(global_rotation.y, puppet.global_rotation.y, damping)

func update_camera(delta):
	var xform = camera.global_transform.looking_at(puppet.global_transform.origin + Vector3(0, 3, 0), Vector3.UP)
	var interpolated_xform = camera.global_transform.interpolate_with(xform, damping)
	interpolated_xform.origin.y = lerp(camera.global_transform.origin.y, xform.origin.y, y_damping)
	camera.global_transform = interpolated_xform
