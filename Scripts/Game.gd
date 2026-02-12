extends Node2D

@export var beats_visible := 8.0

var max_health := 7
var player_health := max_health

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
var first_note_time

var rand = 0
var note = load("res://Scenes/Note.tscn")

var chart: ChartLoader
var sec_per_beat: float
var next_note

const DURATION_NAME_TO_NOTE_VALUE := {
	"whole": 4.0,
	"half": 2.0,
	"quarter": 1.0,
	"eighth": 0.5,
	"sixteenth": 0.25,
	"dotted-half": 3.0,
	"dotted-quarter": 1.5,
	"dotted-eighth": 0.75
}

func duration_to_beats(duration_name: String, beat_unit: int) -> float:
	var note_value = DURATION_NAME_TO_NOTE_VALUE[duration_name]
	return note_value / (4.0 / beat_unit)


func _ready():
	chart = ChartLoader.new()
	chart.load_chart("res://Charts/song1.json")

	sec_per_beat = 60.0 / chart.bpm
	$Conductor.bpm = chart.bpm
	$Conductor.song_position = -beats_visible * sec_per_beat

	next_note = chart.get_next_note()
	
	$HeartContainer/Layout.initialize(max_health, player_health)

func _input(event):
	if event.is_action("escape"):
		if get_tree().change_scene_to_file("res://Scenes/Menu.tscn") != OK:
			print ("Error changing scene to Menu")

func _physics_process(_delta):
	var song_time = $Conductor.song_position
	var first_note = chart.notes[0]
	var first_beat = first_note["beat"]
	first_note_time = first_beat * sec_per_beat + chart.offset

	
	if song_time >= first_note_time and !$Conductor.playing_audio:
		$Conductor.play()
		$Conductor.playing_audio = true

	while next_note != null:
		var beat = next_note["beat"]
		var note_time = beat * sec_per_beat + chart.offset
		
		var travel_time = beats_visible * sec_per_beat
		var spawn_time = note_time - travel_time


		if song_time >= spawn_time:
			_spawn_chart_note(
				next_note["note"],
				next_note["duration"],
				note_time
			)

			chart.advance()
			next_note = chart.get_next_note()
		else:
			break


func _spawn_chart_note(lane, duration, note_time):
	var duration_beats = duration_to_beats(duration, chart.beat_unit)
	var instance = note.instantiate()
	instance.initialize(
		self,
		lane,
		duration_beats,
		sec_per_beat,
		note_time,
		$Conductor,
		beats_visible
	)
	$PlayableSheet.add_child(instance)


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
	apply_damage(1)

func apply_damage(amount):
	player_health = max(player_health - amount, 0)
	$HeartContainer/Layout.set_health(player_health)
	
	if player_health <= 0:
		game_over()

func game_over():
	var result = get_tree().change_scene_to_file("res://Scenes/End.tscn")
	if result != OK:
		print("Error changing scene to End")
