extends CanvasLayer

@onready var p1_score_label = $P1Score
@onready var p2_score_label = $P2Score

@onready var game_timer = $GameTimer
@onready var time_label = $ColorRect/TimeLeftLabel

@onready var event_text = $EventTextLabel

var p1_score = 0
var p2_score = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.letter_collected.connect(_on_letter_collected)
	Global.on_hit.connect(_on_hit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_label.text = "[center]" + str(int(game_timer.time_left))
	pass


func _on_letter_collected(letter,score, p1):
	if p1:
		p1_score += score
		p1_score = clamp(p1_score, 0, 9999)
		p1_score_label.text = "[center]" + str(p1_score) + " PTS"
	else:
		p2_score += score
		p2_score = clamp(p2_score, 0, 9999)
		p2_score_label.text = "[center]" + str(p2_score) + " PTS"

func _on_hit(p1: bool):
	if p1:
		p1_score -= 50
		p1_score = clamp(p1_score, 0, 9999)
		p1_score_label.text = "[center]" + str(p1_score) + " PTS"
	else:
		p2_score -= 50
		p2_score = clamp(p2_score, 0, 9999)
		p2_score_label.text = "[center]" + str(p2_score) + " PTS"

func _on_game_timer_timeout():
	#pause scene
	if p1_score > p2_score:
		event_text.text = "[center]RED Wins!"
	elif p1_score < p2_score:
		event_text.text = "[center]BLUE Wins!"
	else:
		event_text.text = "[center]Draw!"
	var tween = create_tween()
	tween.tween_property(event_text, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	#get_tree().paused = true
	$RestartTimer.start(3)
	#timer.set_process(true)
	#add_child(timer)
	#timer.start(3)
	await $RestartTimer.timeout
	get_tree().reload_current_scene()
