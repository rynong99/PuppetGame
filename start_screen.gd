extends Node2D

@onready var title = $Title

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	get_tree().paused = true
	var tween = create_tween()
	tween.tween_property(title, "scale", Vector2(0.9, 0.9), 0.5)
	tween.tween_property(title, "scale", Vector2(0.74,0.74), 0.5)
	tween.set_loops()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var p1_lean = Input.get_axis("arm_back", "arm_forward")
	var p2_lean = Input.get_axis("hand_down", "hand_up")

	if p1_lean >= 0.7 and p2_lean >= 0.7:
		visible = false
		get_tree().paused = false
	pass
