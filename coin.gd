extends Area3D

var text = "A"

var points = 100

func _ready():
	$Label3D.text = text
	var tween = create_tween()
	var new_scale = remap(points, 0, 1000, 0.2, 1.0)
	tween.tween_property($Label3D, "scale", Vector3(new_scale, new_scale, new_scale), 0.1)

func _on_body_entered(body:Node3D):
	if body.is_in_group("puppet"):
		body.score += points
		Global.num_letters_present -= 1
		Global.letter_collected.emit(text, points, body.is_in_group("p1"))
		queue_free()