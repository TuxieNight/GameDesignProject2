class_name ChartLoader

extends Node

var bpm: float
var offset: float
var notes: Array = []
var index := 0

func load_chart(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	var data := JSON.parse_string(file.get_as_text()) as Dictionary
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
