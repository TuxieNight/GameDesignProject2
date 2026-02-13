extends Node2D

@export var beats_visible := 8.0
@export_file("*.json") var chart_path: String
@export_file("*.tscn") var next_scene_path: String

var max_health := 7
var player_health := max_health

var score = 0
var combo = 0

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

var bpm: float
var sec_per_beat: float

var song_time := 0.0
var playing_audio := false

var chart: ChartLoader
var next_note
var first_note_time: float

var chart_end_time := 0.0

var note_scene := load("res://Scenes/Note.tscn")

@onready var synth := $ChartSynthPlayer


func _ready():
	chart = ChartLoader.new()
	chart.load_chart(chart_path)

	synth.load_chart(chart_path)

	bpm = chart.bpm
	sec_per_beat = 60.0 / bpm

	# Start early enough for notes to scroll in
	song_time = -beats_visible * sec_per_beat

	next_note = chart.get_next_note()

	var first = chart.notes[0]
	first_note_time = first["beat"] * sec_per_beat + chart.offset

	chart_end_time = synth.get_song_end_time()

	$HeartContainer/Layout.initialize(max_health, player_health)


func _input(event):
	if event.is_action("escape"):
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")


func _physics_process(delta):
	song_time += delta

	# Start audio when first note reaches hit time
	if !playing_audio and song_time >= first_note_time:
		playing_audio = true
		synth.play()

	# Spawn notes when their spawn_time is reached
	while next_note != null:
		var beat = next_note["beat"]
		var note_time = beat * sec_per_beat + chart.offset

		var travel_time = beats_visible * sec_per_beat
		var spawn_time = note_time - travel_time

		if song_time >= spawn_time:
			_spawn_chart_note(
				next_note["note"],
				next_note["duration"],
				note_time,
				chart.index
			)

			chart.advance()
			next_note = chart.get_next_note()
		else:
			break

	# End scene after song finishes
	if playing_audio and song_time >= chart_end_time + 4.5:
		get_next_scene()


func _spawn_chart_note(lane, duration_name, note_time, note_index):
	var duration_beats = duration_to_beats(duration_name, chart.beat_unit)
	var instance = note_scene.instantiate()

	instance.initialize(
		self,
		lane,
		duration_beats,
		duration_name,
		sec_per_beat,
		note_time,
		beats_visible,
		note_index
	)

	$PlayableSheet.add_child(instance)


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
		max_combo = max(max_combo, combo)
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
	get_tree().change_scene_to_file("res://Scenes/End.tscn")
	
func get_next_scene():
	get_tree().change_scene_to_file(next_scene_path)
