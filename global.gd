extends Node

signal new_letter(letter: String)
signal letter_collected(letter: String, p1 : bool)
signal new_event(event: String)
signal on_hit(p1: bool)

var num_letters_present = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
