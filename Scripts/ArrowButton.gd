extends AnimatedSprite2D

var perfect := false
var good := false
var okay := false
var current_note = null

@export var input := ""

func _unhandled_input(event):
	# --- PRESS ---
	if event.is_action_pressed(input, false):
		frame = 1

		if current_note != null:
			if current_note.is_hold:
				# Award timing score for the START of the hold
				var score := _get_timing_score()
				get_parent().increment_score(score)
				current_note.register_initial_hit(score)
				current_note.start_hold()
			else:
				# TAP NOTE scoring
				var score := _get_timing_score()
				get_parent().increment_score(score)
				current_note.destroy(score)
				_reset()
		else:
			# No note in lane
			get_parent().increment_score(0)

	# --- RELEASE ---
	if event.is_action_released(input):
		$PushTimer.start()
		frame = 0

		if current_note != null and current_note.is_hold:
			current_note.release_hold()
			_reset()

func _get_timing_score() -> int:
	if perfect:
		return 3
	elif good:
		return 2
	elif okay:
		return 1
	return 0

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
		current_note = area

func _on_OkayArea_area_exited(area):
	if area.is_in_group("note"):
		okay = false
		current_note = null

func _on_PushTimer_timeout():
	frame = 0

func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false
