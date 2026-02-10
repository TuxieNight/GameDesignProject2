class_name ChartLoader

extends Node

var bpm: float
var offset: float
var notes: Array = []
var index := 0
var beat_unit


func load_chart(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	var data := JSON.parse_string(file.get_as_text()) as Dictionary
	var time_signature_string = data.get("time_signature", "4/4")
	var parts = time_signature_string.split("/")
	var beats_per_measure := int(parts[0])
	beat_unit = int(parts[1])  # 4 = quarter, 8 = eighth, etc.

	file.close()
	

	bpm = data["bpm"]
	offset = data["offset"]
	notes = data["notes"]
	index = 0

func get_next_note():
	if index >= notes.size():
		return null
	return notes[index]

func advance():
	index += 1
