extends Node2D

var score = 0
var combo = 0

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

var bpm = 115

var song_position = 0.0
var song_position_in_beats = 0
var last_spawned_beat = 0

var spawn_1_beat = 0
var spawn_2_beat = 0
var spawn_3_beat = 1
var spawn_4_beat = 0

var lane = 0
var rand = 0
var note = load("res://Scenes/Note.tscn")
var instance

var chart: ChartLoader
var sec_per_beat: float
var next_note

func _ready():
	chart = ChartLoader.new()
	chart.load_chart("res://Charts/song1.json")

	sec_per_beat = 60.0 / chart.bpm
	$Conductor.bpm = chart.bpm
	$Conductor.play_with_beat_offset(8)

	next_note = chart.get_next_note()

func _input(event):
	if event.is_action("escape"):
		if get_tree().change_scene_to_file("res://Scenes/Menu.tscn") != OK:
			print ("Error changing scene to Menu")

func _physics_process(delta):
	var song_time = $Conductor.song_position

	while next_note != null:
		var note_time = next_note["beat"] * sec_per_beat + chart.offset

		if song_time >= note_time:
			_spawn_chart_note(next_note["note"])
			chart.advance()
			next_note = chart.get_next_note()
		else:
			break


func _spawn_chart_note(lane):
	var duration = next_note.get("duration", 0.0)
	var instance = note.instantiate()
	instance.initialize(
		lane,
		duration,
		sec_per_beat,
		$Conductor.song_position,
		$Conductor
	)
	add_child(instance)


func increment_score(by):
	if by > 0:
		combo += 1
	else:
		combo = 0
	
	if by == 3:
		great += 1
	elif by == 2:
		good += 1
	elif by == 1:
		okay += 1
	else:
		missed += 1
	
	
	score += by * combo
	$Label.text = str(score)
	if combo > 0:
		$Combo.text = str(combo) + " combo!"
		if combo > max_combo:
			max_combo = combo
	else:
		$Combo.text = ""


func reset_combo():
	combo = 0
	$Combo.text = ""
