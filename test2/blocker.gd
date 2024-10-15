extends Area3D

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = $"../UI/HealthBar".get_global_mouse_position()
	global_position.x = remap(mouse_pos.x, 0, 1200, -1.5, 1.5)
	global_position.y = remap(mouse_pos.y, 0, 720, 1, -1)
	pass


func _on_body_entered(body):
	body.queue_free()
	score += 10
	pass # Replace with function body.
