extends Node3D

@onready var collectable = preload("res://coin.tscn")
@onready var spawn_points = get_children()

@export var spawn_rate := 5.0

var letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
#scrabble point values
var points = [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]

var time_since_spawn := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var coin = collectable.instantiate()
	var letter_id = randi() % letters.size()
	coin.text = letters[letter_id]
	coin.points = points[letter_id] * 100
	Global.new_letter.emit(letters[letter_id])
	spawn_point.add_child(coin)
	letters.remove_at(letter_id)
	points.remove_at(letter_id)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Global.num_letters_present <= 5:
		time_since_spawn += delta
		if time_since_spawn >= spawn_rate:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			if spawn_point.get_child_count() > 0:
				time_since_spawn = 2.5
				return
			var coin = collectable.instantiate()
			if letters.size() > 0:
				var letter_id = randi() % letters.size()
				coin.text =letters[letter_id]
				coin.points = points[letter_id] * 100
				Global.new_letter.emit(letters[letter_id])
				letters.remove_at(letter_id)
				points.remove_at(letter_id)
				spawn_point.add_child(coin)
				Global.num_letters_present += 1
				time_since_spawn = 0.0
