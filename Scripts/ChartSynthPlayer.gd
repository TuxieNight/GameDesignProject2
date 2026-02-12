extends Node

@export var C3: AudioStream
@export var C4: AudioStream
@export var C5: AudioStream

var chart_data
var bpm: float
var offset: float
var sec_per_beat: float

var is_playing := false
var next_index := 0


func load_chart(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	chart_data = JSON.parse_string(text)
	bpm = chart_data["bpm"]
	offset = chart_data["offset"]
	sec_per_beat = 60.0 / bpm

	next_index = 0


func play():
	is_playing = true


func _physics_process(delta):
	if !is_playing or chart_data == null:
		return

	var song_time = get_parent().song_time

	while next_index < chart_data["notes"].size():
		var note = chart_data["notes"][next_index]
		var beat = note["beat"]
		var name = note["note"]

		var note_time = beat * sec_per_beat + offset

		if song_time >= note_time:
			_play_note_immediately(name)
			next_index += 1
		else:
			break


func _play_note_immediately(name: String):
	var semitones := _note_to_semitones(name)
	var sample_data = _choose_sample(semitones)

	var player := AudioStreamPlayer.new()
	add_child(player)

	player.stream = sample_data.stream
	player.pitch_scale = pow(2.0, float(semitones - sample_data.offset) / 12.0)
	player.play()

	# cleanup
	player.connect("finished", player.queue_free)


func _choose_sample(semitones: int):
	if semitones <= -6:
		return {"stream": C3, "offset": -12}
	elif semitones >= 6:
		return {"stream": C5, "offset": 12}
	else:
		return {"stream": C4, "offset": 0}


func _note_to_semitones(note_name: String) -> int:
	var letter := note_name.substr(0, note_name.length() - 1)
	var octave := int(note_name.substr(note_name.length() - 1, 1))

	var table := {
		"C": 0, "C#": 1, "Db": 1,
		"D": 2, "D#": 3, "Eb": 3,
		"E": 4,
		"F": 5, "F#": 6, "Gb": 6,
		"G": 7, "G#": 8, "Ab": 8,
		"A": 9, "A#": 10, "Bb": 10,
		"B": 11
	}

	var midi = (octave + 1) * 12 + table[letter]
	var midi_C4 := (4 + 1) * 12
	return midi - midi_C4
