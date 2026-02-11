extends AnimatedSprite2D

# All notes currently inside the timing window
var notes_in_lane: Array = []

# Timing window flags (lane-wide, but safe now)
var perfect := false
var good := false
var okay := false

@export var input := ""

func _unhandled_input(event):
	# --- PRESS ---
	if event.is_action_pressed(input, false):
		frame = 1

		if notes_in_lane.size() > 0:
			_handle_note_hits()
		else:
			# No note in lane
			get_parent().increment_score(0)

	# --- RELEASE ---
	if event.is_action_released(input):
		$PushTimer.start()
		frame = 0

		# Release all hold notes currently active
		for note in notes_in_lane:
			if note.is_hold:
				note.release_hold()

	_reset_timing_flags()


# ---------------------------------------------------------
# NOTE HIT HANDLING
# ---------------------------------------------------------

func _handle_note_hits():
	for note in notes_in_lane:
		var score := _get_timing_score()
		get_parent().increment_score(score)

		if note.is_hold:
			note.register_initial_hit(score)
			note.start_hold()
		else:
			note.destroy(score)

	# After scoring, clear notes
	notes_in_lane.clear()


# ---------------------------------------------------------
# TIMING WINDOWS
# ---------------------------------------------------------

func _get_timing_score() -> int:
	if perfect:
		return 3
	elif good:
		return 2
	elif okay:
		return 1
	return 0


func _reset_timing_flags():
	perfect = false
	good = false
	okay = false


# ---------------------------------------------------------
# AREA SIGNALS
# ---------------------------------------------------------

func _on_PerfectArea_area_entered(area):
	if area.is_in_group("note"):
		perfect = true

func _on_PerfectArea_area_exited(area):
	if area.is_in_group("note"):
		perfect = false


func _on_GoodArea_area_entered(area):
	if area.is_in_group("note"):
		good = true

func _on_GoodArea_area_exited(area):
	if area.is_in_group("note"):
		good = false


func _on_OkayArea_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		notes_in_lane.append(area)

func _on_OkayArea_area_exited(area):
	if area.is_in_group("note"):
		notes_in_lane.erase(area)

		# If no notes remain, clear timing window
		if notes_in_lane.is_empty():
			okay = false


# ---------------------------------------------------------
# MISC
# ---------------------------------------------------------

func _on_PushTimer_timeout():
	frame = 0
