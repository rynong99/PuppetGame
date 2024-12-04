extends RigidBody3D
class_name Projectile

var id = -1
var time_since_spawn = 0.0

var p1_shot = false

@onready var collision_shape = $CollisionShape3D
@onready var mesh = $MeshInstance3D

const MAX_MASS = 5.0


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.tween_property(collision_shape, "scale", collision_shape.scale * 4, 0.5)
	connect("body_entered", _on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	time_since_spawn += delta
	if time_since_spawn > 5.0 and mass < 1.0:
		queue_free()
	collision_shape.scale = lerp(collision_shape.scale, Vector3.ZERO, delta * 0.1)
	mass = lerp(mass, 0.05, delta * 0.1)
	if collision_shape.scale.length() < 0.1:
		queue_free()
# Called when the projectile collides with another body.
func _on_body_entered(body):
	if body.is_in_group("projectile"):
		if body.p1_shot != p1_shot:
			return
		if body.mass < mass or (body.mass == mass and body.id > id):
			if body.mass >= MAX_MASS or mass >= MAX_MASS:
				attatch_to(body)
			else:
				absorb(body)
	if body.is_in_group("puppet"):
		if body.is_in_group("p1") and !p1_shot:
			Global.on_hit.emit(body.is_in_group("p1"))
		elif !body.is_in_group("p1") and p1_shot:
			Global.on_hit.emit(body.is_in_group("p1"))

func absorb(other_projectile):
	other_projectile.freeze = true
	var scale_change =  1 + (other_projectile.mass / mass)
	mass += other_projectile.mass
	other_projectile.queue_free()
	print(scale_change)
	var tween = create_tween()
	tween.tween_property(collision_shape, "scale", collision_shape.scale * scale_change, 0.1)
	time_since_spawn = 0.0

func attatch_to(other_projectile) -> bool:
	var pinjoint = PinJoint3D.new()
	#pinjoint.global_position = global_position.move_toward(other_projectile.global_position, 0.5)
	pinjoint.global_position = global_position
	pinjoint.node_a = self.get_path()
	pinjoint.node_b = other_projectile.get_path()
	get_parent().add_child(pinjoint)
	return true

# func combine_with(other_projectile) -> bool:
# 	other_projectile.freeze = true
# 	mass += other_projectile.mass
# 	linear_velocity += other_projectile.linear_velocity
# 	#freeze = true
# 	for child in other_projectile.get_children():
# 		var child_pos = child.global_position
# 		child.get_parent().remove_child(child)
# 		add_child(child)
# 		child.global_position = child_pos
# 		#move child position slightly closer to the center of the parent
# 		child.position = child.position * 0.9
# 		#tween child scale
# 		var tween = create_tween()
# 		tween.tween_property(child, "scale", child.scale * 2, 0.1)
# 	#freeze = false
# 	other_projectile.queue_free()
# 	if mass >= MAX_MASS:
# 		sleeping = true
# 	return true
	
